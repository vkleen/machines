#!/usr/bin/env cached-nix-shell
#!nix-shell -i zsh
#!nix-shell -p jq awscli2 zsh

# This might break in future revision of cached-nix-shell
# Too lazy to report the bug
shift

LAUNCH_TEMPLATE=nixos-build
SERVER_ARCH=x86_64-linux,i686-linux
case "$1" in
    --arm64)
      LAUNCH_TEMPLATE=nixos-arm64-build
      SERVER_ARCH=aarch64-linux,armv7l-linux,armv6l-linux
      shift;;
esac

set -e

DIR=${0:a:h}
AWS=(aws --region eu-central-1)

launch-spot-request() {
    "$AWS[@]" ec2 run-instances \
        --launch-template LaunchTemplateName="${LAUNCH_TEMPLATE}" \
        --instance-market-options MarketType=spot,"SpotOptions={SpotInstanceType=one-time,InstanceInterruptionBehavior=terminate}" \
        --user-data file://<(cat "$DIR"/amazon.nix) | \
        jq -r '.Instances[0].InstanceId'
}

wait-for-public-dns() {
    local result=
    while [[ -z "$result" ]]; do
        result=$("$AWS[@]" ec2 describe-instances --instance-ids "$1" | jq -r '.Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicDnsName')
        case "$result" in
            null) result="" ;;
            *) break ;;
        esac
        sleep 1
    done
    echo "$result"
}

terminate-instance() {
    "$AWS[@]" ec2 terminate-instances --instance-ids "$1"
}

build_cmdline=( "${@}" )

nix "${build_cmdline[@]}" && exit

cleanup() {
    terminate-instance "$INSTANCE"
}
trap cleanup EXIT INT TERM ERR
INSTANCE=$(launch-spot-request)

echo "Waiting for instance $INSTANCE to come up..."
SERVER=$(wait-for-public-dns "$INSTANCE")
echo "Instance $INSTANCE is booting at $SERVER; wait for ssh to start..."

get_ssh_host_key() {
    local result=
    while [[ -z "$result" ]]; do
        sleep 1
        result=$("$AWS[@]" ec2 get-console-output --latest --query Output --output text --instance-id "$INSTANCE" |
            awk '/-----BEGIN SSH HOST KEY-----/{f=1;next;}/^-----END SSH HOST KEY-----/{exit 1;} f{ if($1 == "ssh-ed25519") { print $1 " " $2; exit 0; } }' || exit 1)
    done
    echo "$result"
}

SSH_HOST_KEY=$(get_ssh_host_key)

do_nix() {
  local cmdline=( "${@}" )
  nix --option builders-use-substitutes true --builders "ssh://${SERVER} ${SERVER_ARCH} ${HOME}/.ssh/id_rsa 18 - benchmark,kvm,recursive-nix,big-parallel,ca-derivations - $(base64 -w0 <<<"$SSH_HOST_KEY")" "${cmdline[@]}"
}

do_ssh() {
  local cmdline=( "${@}" )
  () {
    trap "rm -f $1" ERR
    ssh -o UserKnownHostsFile="$1" -o HostKeyAlias=aws-ec2 "${cmdline[@]}"
  } =(echo aws-ec2 $SSH_HOST_KEY)
}

#do_ssh root@"$SERVER" -- systemctl restart nix-daemon
do_nix "${build_cmdline[@]}"

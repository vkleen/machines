#!/usr/bin/env cached-nix-shell
#!nix-shell -i zsh
#!nix-shell -p jq awscli zsh

# This might break in future revision of cached-nix-shell
# Too lazy to report the bug
shift

MOSH=
case "$1" in
    -m) MOSH=1; shift;;
esac

set -e

AWS=(aws --region eu-central-1)

launch-spot-request() {
    "$AWS[@]" ec2 run-instances \
        --launch-template LaunchTemplateName=nixos-build \
        --instance-market-options MarketType=spot,"SpotOptions={SpotInstanceType=one-time,InstanceInterruptionBehavior=terminate}" \
        --user-data file://<(cat amazon.nix) | \
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

nix -L build -j0 "${build_cmdline[@]}" && exit

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
            awk '/^-----BEGIN SSH HOST KEY-----/{f=1;next;}/^-----END SSH HOST KEY-----/{exit;} f{ if($1 == "ssh-ed25519") { print $1 " " $2; exit; } }')
    done
    echo "$result"
}

SSH_HOST_KEY=$(get_ssh_host_key)

do_nix() {
  local cmdline=( "${@}" )
  nix --option builders-use-substitutes true --builders "ssh://$SERVER x86_64-linux $HOME/.ssh/id_rsa 18 - benchmark,kvm,recursive-nix,big-parallel - $(base64 -w0 <<<"$SSH_HOST_KEY")" "${cmdline[@]}"
}

do_nix -v -L build -j0 "${build_cmdline[@]}"

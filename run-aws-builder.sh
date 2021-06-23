#!/usr/bin/env cached-nix-shell
#!nix-shell -i zsh
#!nix-shell -p jq awscli openssh mosh zsh

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

DRV=
if [[ -z "${1}" ]]; then
  echo "Missing derivation"
  exit 1
else
  DRV=${1}
fi
echo "Building ${DRV}"

INSTANCE=$(launch-spot-request)
cleanup() {
    terminate-instance "$INSTANCE"
}
trap cleanup EXIT INT TERM ERR

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

do_ssh() {
    local cmd="$1"
    shift 1
    local cmdline=( "${@}" )
    () {
        trap "rm $1" ERR
        "$cmd" -o UserKnownHostsFile="$1" -o HostKeyAlias=aws-ec2 "${cmdline[@]}"
    } =(echo aws-ec2 $SSH_HOST_KEY)
}

do_ssh ssh root@"$SERVER" <<EOF
  mkdir /private
EOF
do_ssh scp secrets/cache-keys/aws-vkleen-nix-cache-1.private root@"$SERVER":/private/
do_ssh scp -r secrets/cache-keys/aws root@"$SERVER":/root/.aws
do_ssh scp ~/PragmataPro0.829.zip root@"$SERVER":~
nix copy -s --derivation "$DRV" --to ssh://root@"$SERVER"
#nix-store --export $(nix-store -qR "$DRV") | pv | do_ssh ssh root@"$SERVER" "nix-store --import"

do_ssh ssh root@"$SERVER" <<EOF
  systemd-run --user --scope tmux new-session -d -s persistent
  tmux send-keys -t persistent "nixos-rebuild switch && nix-store --add-fixed sha256 ~/PragmataPro0.829.zip && nix -L build \"$DRV\" && nix sign-paths --all -k /private/aws-vkleen-nix-cache-1.private && nix copy --all --to 's3://vkleen-nix-cache?region=eu-central-1' && exit" ENTER
EOF
if [[ -n "$MOSH" ]]; then
    () {
      trap "rm $1" ERR
      mosh --ssh="ssh -o UserKnownHostsFile=$1 -o HostKeyAlias=aws-ec2" root@"$SERVER" -- tmux attach -d -t persistent || true
    } =(echo aws-ec2 $SSH_HOST_KEY)
else
    do_ssh ssh -t root@"$SERVER" -- tmux attach -d -t persistent || true
fi
terminate-instance "$INSTANCE"
trap - EXIT INT TERM ERR
DRVOUT=$(nix show-derivation "$DRV" | jq -r ' . | keys[] as $k | .[$k].outputs.out.path')
nix copy --from 's3://vkleen-nix-cache?region=eu-central-1' "$DRVOUT"
nix build -j0 "$DRVOUT"

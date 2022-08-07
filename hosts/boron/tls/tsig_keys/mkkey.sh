#!/usr/bin/env nix-shell
#!nix-shell -i zsh
#!nix-shell -p knot-dns rage yq

usage() {
  echo "mkkey.sh <basename>"
  exit 1
}

if [[ -z "$1" ]]; then usage; fi

_base=$(realpath $(dirname "${0}"))

rage -i ~/.ssh/id_ed25519 -d "${_base}/../../../neodymium/dns/keys/${1}_acme.age" | \
  yq -r '.key[0].secret' | \
  rage -r "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkRtSje5rDeMMd6wZFbQ1d9XlF9nqeRf40vZ8y+x1/J" \
       -r "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b" \
       -o "${_base}/${1}.age"

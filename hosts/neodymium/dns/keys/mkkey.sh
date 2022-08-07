#!/usr/bin/env nix-shell
#!nix-shell -i zsh
#!nix-shell -p knot-dns rage

usage() {
  echo "mkkey.sh <basename>"
  exit 1
}

if [[ -z "$1" ]]; then usage; fi

keymgr -t "${1}_key" | \
  rage -r "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/rujrnskTy66GPBnKnWbwf45I7pWEjcXyaQoVHgDG8" \
       -r "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b" \
       -o "$(realpath $(dirname "${0}"))/${1}.age"

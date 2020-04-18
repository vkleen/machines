#!/usr/bin/env cached-nix-shell
#!nix-shell -i bash
#!nix-shell -p curl jq nix

set -eufo pipefail

# This might break in future revision of cached-nix-shell
# Too lazy to report the bug
shift
FILE=$1
BRANCH=${2:-master}

OWNER=$(jq -r '.owner' < "$FILE")
REPO=$(jq -r '.repo' < "$FILE")

REV=$(curl "https://api.github.com/repos/$OWNER/$REPO/branches/$BRANCH" | jq -r '.commit.sha')
SHA256=$(nix-prefetch-url "https://github.com/$OWNER/$REPO/archive/$REV.tar.gz")
HASH=$(nix to-sri --type sha256 "$SHA256")
TJQ=$(jq '. = {owner: $owner, repo: $repo, rev: $rev, hash: $hash}' \
   --arg owner "$OWNER" \
   --arg repo "$REPO" \
   --arg rev "$REV" \
   --arg hash "$HASH" < "$FILE")

[[ $? == 0 ]] && echo "${TJQ}" >| "$FILE"

#!/usr/bin/env nix-shell
#!nix-shell -i bash
#!nix-shell -p curl jq nix

set -eufo pipefail

FILE=$1
BRANCH=${2:-master}

OWNER=$(jq -r '.owner' < "$FILE")
REPO=$(jq -r '.repo' < "$FILE")

REV=$(curl "https://api.github.com/repos/$OWNER/$REPO/branches/$BRANCH" | jq -r '.commit.sha')
SHA256=$(nix-prefetch-url "https://github.com/$OWNER/$REPO/archive/$REV.tar.gz")
TJQ=$(jq '. = {owner: $owner, repo: $repo, rev: $rev, sha256: $sha256}' \
   --arg owner "$OWNER" \
   --arg repo "$REPO" \
   --arg rev "$REV" \
   --arg sha256 "$SHA256" < "$FILE")

[[ $? == 0 ]] && echo "${TJQ}" >| "$FILE"

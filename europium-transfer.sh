#!/usr/bin/env bash

_id=$(linode-cli --suppress-warnings --json linodes list | jq '.[] | select(.label == "europium") | .id')

linode-cli --suppress-warnings --json linodes transfer-view "$_id" | \
  jq -r '.[] | .used / (1024.0*1024*1024) | ceil | tostring + " GiB"'

#!/usr/bin/env cached-nix-shell
#!nix-shell -i zsh
#!nix-shell -p jq awscli zsh

for r in $(aws ec2 describe-regions | \
            jq -r '.Regions[] | .RegionName' \
          ); do
  aws --region "$r" ec2 describe-instances --filters Name=instance-state-name,Values=running | \
    jq -r '.Reservations[] | .Instances[] | "'"$r"': " + .InstanceId + " " + .InstanceType + " " + .NetworkInterfaces[0].Association.PublicDnsName'
done

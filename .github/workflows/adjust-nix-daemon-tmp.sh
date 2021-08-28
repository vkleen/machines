#!/bin/sh

mkdir -p /etc/systemd/system/nix-daemon.service.d /nix/tmp || true
cp .github/workflows/nix-daemon-env.conf /etc/systemd/system/nix-daemon.service.d/
systemctl daemon-reload
systemctl restart nix-daemon

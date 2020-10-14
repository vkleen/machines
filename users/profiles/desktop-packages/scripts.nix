{ pkgs, nixos, ... }:
let update-chlorine-boot = pkgs.writeScriptBin "update-chlorine-boot" ''
      #!${pkgs.stdenv.shell}
      ssh -t chlorine -- update-boot
      scp root@chlorine:/boot/\* $HOME/machines/chlorine/boot/
      chmod 644 $HOME/machines/chlorine/boot/*
    '';

    wx = pkgs.writeScriptBin "wx" ''
      #!${pkgs.stdenv.shell}
      station=''${1:-EDDL}
      token="j2FnxQRDqozXVbYhpEv_tncUI4oKgAT75HCbTnRB5Ig"

      curl --header "Authorization: Token ''${token}" \
           "https://avwx.rest/api/taf/''${station}" "https://avwx.rest/api/metar/''${station}" 2>/dev/null \
                | jq -r '.raw'
    '';

    update-envrc = pkgs.writeScriptBin "update-envrc" ''
      #!${pkgs.stdenv.shell}
      SHELLNIX=''${1:-shell.nix}

      DIRENV=${pkgs.direnv}/bin/direnv

      mkdir -p .gcroots

      nix-instantiate "''${SHELLNIX}" --indirect --add-root "$PWD"/.gcroots/shell.drv
      nix-shell "$(readlink "$PWD"/.gcroots/shell.drv)" --run 'unset ''${!SSH_@} ''${!DIRENV_@} shellHook TEMP TEMPDIR TMP TMPDIR SSL_CERT_FILE NIX_SSL_CERT_FILE ''${!DBUS@} ''${!DESKTOP@} ''${!XDG@} ''${!TMUX@} I3SOCK TERM && '"$DIRENV"' dump bash > '"''${2:-.envrc.cache}"' '
    '';

    update-flake-cache = pkgs.writeScriptBin "update-flake-cache" ''
      #!${pkgs.stdenv.shell}
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      pwd_hash=$(basename $PWD)-$(echo -n $PWD | b2sum | cut -d ' ' -f 1)
      direnv_layout_dir=$XDG_CACHE_HOME/direnv/layouts/$pwd_hash
      mkdir -p $direnv_layout_dir

      nix print-dev-env > "$direnv_layout_dir/flake-cache"
    '';

    power-cycle = pkgs.writeScriptBin "power-cycle" ''
      #!${pkgs.expect}/bin/expect -f

      proc shift {list} {
        set result ""
        upvar 1 $list ll
        set ll [lassign $ll result]
        return $result
      }

      proc usage_exit {} {
        send_user [subst -nocommand {Usage: $::argv0 <interface number> [on|off]\n}]
        exit 1
      }

      if {[llength $argv] == 0 || [llength $argv] > 2} {
        usage_exit
      }

      set interface [format "ge-0/0/%d" [shift argv]]

      set on 1
      set off 1

      if {[llength $argv] == 1} {
        switch -- [shift argv] {
          on { set off 0 }
          off { set on 0 }
          default { usage_exit }
        }
      }

      log_user 0

      spawn ssh lead-mgmt
      expect "root@lead:RE:0% "
      send "cli\r"
      expect "root@lead> "
      send "set cli screen-length 0\r"
      expect "root@lead> "

      send "configure\r"
      expect "root@lead# "
      if { $off } {
        send_user "Turning off $interface..."
        send "set poe interface $interface disable\r"
        expect "root@lead# "
        send "commit\r"
        expect "root@lead# "
        send_user " ✓\n"
      }
      if { $on } {
        if { $off } { sleep 1 }
        send_user "Turning on  $interface..."
        send "delete poe interface $interface\r"
        expect "root@lead# "
        send "commit\r"
        expect "root@lead# "
        send_user " ✓\n"
      }

      send "exit\r"
      expect "root@lead> "
      send "\x01\x18"
    '';
in {
  home.packages = [
    update-chlorine-boot
    wx
    update-envrc update-flake-cache
    power-cycle
  ];
}

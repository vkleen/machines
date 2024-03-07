{ pkgs, lib, ... }:
let
  askPassword = pkgs.writeShellScript "ask-password" ''
    _prompt=$@
    if [[ -z "''${_prompt}" ]]; then
      _prompt="SSH passphrase:"
    fi
    exec ${lib.getExe pkgs.fuzzel} -p "''${_prompt}" --password --dmenu -l 0 2>/dev/null
  '';
in
{
  systemd.user.services.ssh-agent = {
    Install.WantedBy = [ "default.target" ];
    Service =
      {
        ExecStartPre = "${pkgs.coreutils}/bin/rm -f %t/ssh-agent";
        ExecStart =
          "${pkgs.openssh}/bin/ssh-agent -t 1h -a %t/ssh-agent";
        StandardOutput = "null";
        Type = "forking";
        Restart = "on-failure";
        SuccessExitStatus = "0 2";
      };
    environment.SSH_ASKPASS = askPassword;
    environment.DISPLAY = "fake"; # required to make ssh-agent start $SSH_ASKPASS
  };

  home.sessionVariablesExtra = ''
    if [ -z "$SSH_AUTH_SOCK" -a -n "$XDG_RUNTIME_DIR" ]; then
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
    fi
  '';

  home.sessionVariables = {
    SSH_ASKPASS = askPassword;
    SSH_ASKPASS_REQUIRE = "prefer";
  };
}

{ pkgs, lib, ... }:
pkgs.writeShellScript "pinentry" ''
  # Base command and misc variables
  DESC=""
  PROMPT=""

  function decode() {
    echo -e "''${*//%/\\x}"
  }

  echo "OK Please go ahead"
  while read cmd rest; do
      case $cmd in
          GETINFO)
              case "$rest" in
                  flavor)
                      echo "D fuzzel"
                      echo "OK"
                      ;;
                  version)
                      echo "D 0.1"
                      echo "OK"
                      ;;
                  ttyinfo)
                      echo "D - - -"
                      echo "OK"
                      ;;
                  pid)
                      echo "D $$"
                      echo "OK"
                      ;;
              esac
              ;;

          SETDESC)
              DESC=$(decode "''${rest}")
              echo "OK"
              ;;

          SETERROR)
              ${lib.getExe pkgs.fuzzel} --prompt-only "''${rest}" --cache /dev/null --password --dmenu
              echo "OK"
              exit 1
              ;;

          SETPROMPT)
              PROMPT="''${rest}"
              echo "OK"
              ;;

          GETPIN | getpin)
              echo "''${DESC}" > /tmp/debug
              echo "D $(${lib.getExe pkgs.fuzzel} --prompt-only "''${DESC}" --placeholder="''${PROMPT}: " --cache /dev/null --password --dmenu)"
              echo "OK"
              ;;

          BYE|bye)
              echo "OK closing connection"
              exit 0
              ;;

          *)
              echo "OK"
              ;;
          esac
  done
''

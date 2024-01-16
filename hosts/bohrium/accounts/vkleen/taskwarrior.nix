{ config, pkgs, lib, ... }:
let
  task = lib.getExe config.programs.taskwarrior.package;
  data = config.programs.taskwarrior.dataLocation;

  blocksHook = pkgs.writers.writePython3Bin "blocksHook"
    {
      flakeIgnore = [ "E302" "E305" "E501" ];
    } ''
    import json
    import os
    import subprocess
    import sys

    # Adjust this if "task" is not regular Taskwarrior.
    TASK = '${task}'
    # Adjust path if needed. It is a temporary file managed by the hook.
    SHIMFILE = "${data}/hooks/blocks_shim.txt"

    def on_launch():
        try:
            with open(SHIMFILE, 'r') as f:
                shim = f.readlines()
        except IOError:
            sys.exit(0)
        while shim:
            line = shim.pop(0).rstrip()
            if not line:
                continue
            if subprocess.call(line.split()) != 0:
                # Error handling by escalating to the user :)
                print("%s ERROR: First line in %s is failing to run!" % (sys.argv[0], SHIMFILE))
                print("Feel free to delete the file, or edit its contents to resolve the problem.")
                shim = [line + '\n'] + shim
                break
        if shim:
            with open(SHIMFILE, 'w') as f:
                f.write('''.join(shim))
            sys.exit(1)
        else:
            os.remove(SHIMFILE)

    def handle_blocks_attribute(new):
        if 'blocks' in new:
            with open(SHIMFILE, "a") as f:
                # This needs error handling. If a later hook aborts, the UUID is invalid.
                f.write("%s rc.hooks=off rc.confirmation=no rc.bulk=10000 rc.verbose=nothing %s mod dep:%s\n" % (TASK, new['blocks'], new['uuid']))
            del new['blocks']
        print(json.dumps(new))

    old = sys.stdin.readline()
    new = sys.stdin.readline()

    if not old:
        on_launch()
    elif not new:
        handle_blocks_attribute(json.loads(old))
    else:
        handle_blocks_attribute(json.loads(new))
  '';

  note = pkgs.writers.writeBashBin "note" ''
    _note_dir="${data}/notes"
    mkdir -p "$_note_dir"

    if [[ $# -eq 1 ]]; then
      uuid=$(${task} _get $1.uuid)
      note="$_note_dir/$uuid.md"
      ${config.home.sessionVariables.EDITOR} "$note" || exit 1

      ${task} "$uuid" mod note:"$(date --iso-8601=seconds)" >/dev/null
    else
      ${config.home.sessionVariables.EDITOR} "$_note_dir"/buffer
    fi
  '';
in
{
  programs.taskwarrior = {
    enable = true;
    dataLocation = "${config.home.homeDirectory}/.task";
    extraConfig = ''
      uda.blocks.type=string
      uda.blocks.label=Blocks

      uda.note.type=date
      uda.note.label=Note
      alias.note=execute "${lib.getExe note}"
    '';
  };

  home.file = {
    "${data}/hooks/on-modify.blocks_attr.py".source = lib.getExe blocksHook;
    "${data}/hooks/on-add.blocks_attr.py".source = lib.getExe blocksHook;
    "${data}/hooks/on-launch.blocks_attr.py".source = lib.getExe blocksHook;
  };
}

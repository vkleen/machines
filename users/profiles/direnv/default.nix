{pkgs, ...}:
let
  update-flake-cache = pkgs.writeScriptBin "update-flake-cache" ''
    #!${pkgs.stdenv.shell}
    : ''${XDG_CACHE_HOME:=$HOME/.cache}
    pwd_hash=$(basename $PWD)-$(echo -n $PWD | b2sum | cut -d ' ' -f 1)
    direnv_layout_dir=$XDG_CACHE_HOME/direnv/layouts/$pwd_hash
    mkdir -p $direnv_layout_dir

    nix print-dev-env > "$direnv_layout_dir/flake-cache"
  '';
in
{
  home.packages = [
    update-flake-cache
  ];
  programs.direnv = {
    enable = true;
    config = {
    };
    stdlib = ''
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      pwd_hash=$(basename $PWD)-$(echo -n $PWD | b2sum | cut -d ' ' -f 1)
      direnv_layout_dir=$XDG_CACHE_HOME/direnv/layouts/$pwd_hash
      mkdir -p $direnv_layout_dir

      use_flake() {
        watch_file "$(direnv_layout_dir)/flake-cache"
        source "$(direnv_layout_dir)/flake-cache"
      }
    '';
  };
}

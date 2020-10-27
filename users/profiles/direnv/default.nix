{pkgs, ...}:
let
  update-flake-cache = pkgs.writeScriptBin "update-flake-cache" ''
    #!${pkgs.stdenv.shell}
    : ''${XDG_CACHE_HOME:=$HOME/.cache}
    eval "$(${pkgs.direnv}/bin/direnv stdlib)"
    envrc_dir=$(dirname $(find_up .envrc))
    pwd_hash=$(basename $envrc_dir)-$(echo -n $envrc_dir | b2sum | cut -d ' ' -f 1)
    direnv_layout_dir=$XDG_CACHE_HOME/direnv/layouts/$pwd_hash
    mkdir -p $direnv_layout_dir

    cd $envrc_dir
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
      envrc_dir=$(dirname $(find_up .envrc))
      pwd_hash=$(basename $envrc_dir)-$(echo -n $envrc_dir | b2sum | cut -d ' ' -f 1)
      direnv_layout_dir=$XDG_CACHE_HOME/direnv/layouts/$pwd_hash
      mkdir -p $direnv_layout_dir

      use_flake() {
        watch_file "$(direnv_layout_dir)/flake-cache"
        source "$(direnv_layout_dir)/flake-cache"
      }
    '';
  };
}

{pkgs, ...}:
let plugins = with pkgs.kakounePlugins; [
      kak-auto-pairs
      kak-fzf
      kak-buffers
      (pkgs.callPackage ./kakoune/kakoune-surround.nix {})
      (pkgs.callPackage ./kakoune/kakoune-change-directory.nix {})

      (pkgs.writeTextFile {
        name = "kak-config";
        text = builtins.readFile ./kakrc;
        destination = "/share/kak/autoload/config.kak";
      })
    ];

    kak = pkgs.kakoune.override {
      configure = {
        inherit plugins;
      };
    };
in {
  home.sessionVariables = {
    EDITOR = "${kak}/bin/kak";
  };

  home.packages = with pkgs; [
    kak
    kak-lsp
  ];
}

{pkgs, ...}:
let plugins = with pkgs.kakounePlugins; [
      kak-auto-pairs
      kak-fzf
      kak-buffers
      (pkgs.callPackage ./kakoune/kakoune-surround.nix {})

      (pkgs.writeTextFile {
        name = "kak-config";
        text = builtins.readFile ./kakrc;
        destination = "/share/kak/autoload/config.kak";
      })
    ];
in {
  home.packages = with pkgs; [
    (kakoune.override {
      configure = {
        inherit plugins;
      };
    })
    kak-lsp
  ];
}

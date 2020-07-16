{ pkgs, lib, ... }:
let
  weechat-scripts = pkgs.fetchFromGitHub {
    owner = "weechat";
    repo = "scripts";
    rev = "3e16849dd1a55902dbad9ac04176639190eedaf0";
    hash = "sha256:0y57dbbalc31sj9z3dfk2a939ms19n4qfm5hqkrka395ij4s6frp";
  };

  weechat-discord = pkgs.rustPlatform.buildRustPackage {
    pname = "weechat-discord";
    version = "master";

    src = pkgs.fetchFromGitHub {
      owner = "vkleen";
      repo = "weechat-discord";
      rev = "0d58c29774c3b806af4f5b3527cef8672cf47114";
      hash = "sha256:0s8zjb3dqnsf6dhnax301ykhr8z8b65k0s1nlf11jk20n60ml5f9";
    };

    cargoSha256 = "1a08famirk4h66hr3xkcm9aidzw9w3c7ly12gdj488y81qlc690k";

    buildInputs = [ pkgs.weechat-unwrapped pkgs.rust-bindgen ];

    postConfigure = ''
        export LIBCLANG_PATH="${pkgs.llvmPackages.clang-unwrapped.lib}/lib"
        export BINDGEN_CFLAGS="$(< ${pkgs.stdenv.cc}/nix-support/libc-cflags) \
          $(< ${pkgs.stdenv.cc}/nix-support/cc-cflags) \
          ${pkgs.stdenv.cc.default_cxx_stdlib_compile} \
          ${
            lib.optionalString pkgs.stdenv.cc.isClang
            "-idirafter ${pkgs.stdenv.cc.cc}/lib/clang/${
              lib.getVersion pkgs.stdenv.cc.cc
            }/include"
          } \
          ${
            lib.optionalString pkgs.stdenv.cc.isGNU
            "-isystem ${pkgs.stdenv.cc.cc}/include/c++/${
              lib.getVersion pkgs.stdenv.cc.cc
            } -isystem ${pkgs.stdenv.cc.cc}/include/c++/${
              lib.getVersion pkgs.stdenv.cc.cc
            }/${pkgs.stdenv.hostPlatform.config}"
          } \
          $NIX_CFLAGS_COMPILE"
    '';
  };

  weechat-notify-send = pkgs.stdenv.mkDerivation {
    name = "weechat-notify-send";
    src = pkgs.fetchFromGitHub {
      owner = "s3rvac";
      repo = "weechat-notify-send";
      rev = "cc701bdebdb1bf550e36aa8b13c59b47905db2dc";
      hash = "sha256:1iy5vag8i17ak32vhd301q14svh0d6axk0iymhy0xhl1zilv3sgv";
    };
    configurePhase = "true";
    buildPhase = "true";
    installPhase = ''
      mkdir "$out"
      substitute "$src"/notify_send.py "$out"/notify_send.py \
        --replace "notify_cmd = ['notify-send'" "notify_cmd = ['${pkgs.libnotify}/bin/notify-send'"
    '';
  };

  weechat = pkgs.weechat.override {
    configure = {availablePlugins, ...}: {
      plugins = builtins.attrValues (availablePlugins // {
        python = (availablePlugins.python.withPackages (ps: with ps; [
          feedparser
          pyopenssl
          webcolors
          future
          atomicwrites
          attrs
          Logbook
          pygments
          matrix-nio
          aiohttp
          requests
          dbus-python
          pkgs.weechatScripts.weechat-matrix
        ]));
        perl = (availablePlugins.perl.withPackages (ps: with ps; [
          XMLFeedPP
        ]));
      });
      scripts = with pkgs.weechatScripts; [
        weechat-matrix
      ];
    };
  };
in {
  options = {
    weechat.weechat-discord = lib.mkOption {
      default = weechat-discord;
      type = lib.types.package;
    };
  };
  config = {
    home.file.".weechat/python/autoload/weemustfeed.py".source =
      "${weechat-scripts}/python/weemustfeed.py";
    home.file.".weechat/python/autoload/notify_send.py".source =
      "${weechat-notify-send}/notify_send.py";
    home.file.".weechat/python/autoload/go.py".source =
      "${weechat-scripts}/python/go.py";
    home.file.".weechat/python/autoload/autosort.py".source =
      "${weechat-scripts}/python/autosort.py";
    home.file.".weechat/python/autoload/urlgrab.py".source =
      "${weechat-scripts}/python/urlgrab.py";
    home.file.".weechat/python/autoload/colorize_nicks.py".source =
      "${weechat-scripts}/python/colorize_nicks.py";
    home.file.".weechat/perl/autoload/multiline.pl".source =
      "${weechat-scripts}/perl/multiline.pl";
    # home.file.".weechat/perl/autoload/rssagg.pl".source =
    #   "${weechat-scripts}/perl/rssagg.pl";

    home.packages = [
      weechat
    ];
  };
}

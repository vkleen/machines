{ pkgs, lib, ... }:
let
  weechat-scripts = pkgs.fetchFromGitHub {
    owner = "weechat";
    repo = "scripts";
    rev = "25f7988014dedd508efa9a3df977c0da623693a9";
    hash = "sha256-qo/+KZDg2A1zjbcFeiDSaRVTXSpKat0UdKmLMPXhMeQ=";
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

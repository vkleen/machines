{pkgs, config, nixos, ...}:
{
  programs.alot = {
    enable = true;
    settings = {
      initial_command = "search tag:inbox AND NOT tag:killed";
      auto_remove_unread = true;
      handle_mouse = true;
      prefer_plaintext = true;
      attachment_prefix = "~/dl";
      editor_cmd = "/etc/profiles/per-user/vkleen/bin/kak";
      envelope_html2txt = "${pkgs.pandoc}/bin/pandoc -f html -t markdown";
    };
  };

  accounts.email = {
    maildirBasePath = "";
    accounts = {
      "vkleen" = {
        alot.sendMailCommand = "${nixos.security.wrapperDir}/sendmail -t";
        notmuch.enable = true;
        primary = true;
        address = "viktor@kleen.org";
        aliases = [ "kleen@usc.edu" "viktor.kleen@uni-due.de" "yasc@yasc.org" "vkleen@17220103.de" ];
        realName = "Viktor Kleen";
        maildir = { path = "mail"; };
        gpg = {
          key = "1FE9015A0610E43C74EFC813744138390330BB39";
          signByDefault = true;
        };
      };
    };
  };
}

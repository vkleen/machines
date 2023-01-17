{flake, pkgs, config, nixos, lib, ...}:
let
  account = config.accounts.email.accounts."vkleen";
  yesno = x: if x then "yes" else "no";

  sendMailCommand = pkgs.writeShellScriptBin "sendmail" ''
    tee >(${pkgs.notmuch}/bin/notmuch insert --folder=sent --create-folder +sent -inbox -unread) | ${nixos.security.wrapperDir}/sendmail -t "$@"
  '';

  new-mail = pkgs.writeShellScriptBin "new-mail" ''
    ${pkgs.coreutils}/bin/tail -n+2 | ${pkgs.notmuch}/bin/notmuch insert
  '';
in {
  imports = [ ./colors.nix ];

  home.packages = [ pkgs.neomutt pkgs.notmuch ];
  xdg.configFile."neomutt/neomuttrc".text = ''
    set header_cache = "${config.xdg.cacheHome}/neomutt/headers/"
    set message_cachedir = "${config.xdg.cacheHome}/neomutt/messages/"
    set editor = "${pkgs.neovim}/bin/nvim"
    set tmpdir = "/run/user/${builtins.toString nixos.users.users.vkleen.uid}"
    set implicit_autoview = yes

    set attach_save_dir = "~/dl/"

    set charset = "utf-8"
    set send_charset = "utf-8"
    set assumed_charset = "utf-8"

    set edit_headers = yes

    set abort_noattach = ask-yes

    alternative_order text/enriched text/plain text

    source ${pkgs.neomutt}/share/doc/neomutt/vim-keys/vim-keys.rc

    set folder = "${account.maildir.absPath}"

    folder-hook ${account.maildir.absPath}/ " \
      source ${config.xdg.configHome}/neomutt/${account.name}"
    source ${config.xdg.configHome}/neomutt/${account.name}
    source ${config.xdg.configHome}/neomutt/colors-selenized
  '';

  home.file."${config.xdg.configHome}/neomutt/${account.name}".text = ''
    set ssl_force_tls = yes
    set certificate_file = ${config.accounts.email.certificatesFile}

    set crypt_use_gpgme = yes
    set crypt_autosign = ${yesno (account.gpg.signByDefault or false)}
    set pgp_use_gpg_agent = yes
    set pgp_default_key = ${account.gpg.key}
    set mbox_type = Maildir

    set sort = threads
    set sort_aux = 'last-date-received'

    set sendmail = '${account.neomutt.sendMailCommand}'
    set use_envelope_from = yes

    virtual-mailboxes "inbox" "notmuch://?query=tag:inbox and not tag:tweag" \
                      "tweag inbox"  "notmuch://?query=tag:inbox and tag:tweag" \
                      "sent"  "notmuch://?query=tag:sent" \
                      "flagged" "notmuch://?query=tag:flagged" \
                      "tweag"  "notmuch://?query=tag:tweag"

    set real_name = '${account.realName}'
    alternates ${lib.concatMapStringsSep " " (a: "'^${a}$'") account.aliases}
    alternates '@17220103.de$' '@as210286.net$' '@zorn-encryption.org$'
    set reverse_name = yes
    set spoolfile = inbox
    unset record
    set postponed = +draft

    set mail_check = 1
    set mail_check_stats = yes
    set mail_check_stats_interval = 60

    set sidebar_visible = yes
    set sidebar_short_path = yes
    set sidebar_width = 22
    set sidebar_format = '%D%* %?N?%N/?%S'

    set query_command = "${pkgs.notmuch}/bin/notmuch address --sort=newest-first --output=sender --output=recipients --deduplicate=address 'from:%s'"
    set query_format = "%5c %t %a %n %?e?(%e)?"

    set nm_default_uri = "notmuch://${account.maildir.absPath}"
    set nm_exclude_tags = deleted
    set nm_record = yes
    set nm_record_tags = sent

    set hidden_tags = "inbox,unread,draft,flagged,passed,replied,signed,encrypted,attachment"
    tag-transforms "attachment" "@" \
                   "encrypted"  "" \
                   "signed"     "✎"
    tag-formats "attachment" "GA" \
                "encrypted"  "GE" \
                "signed"     "GS"

    set index_format = '%4C %S (%D) %-18.18L %?GA?%GA& ?%?GE?%GE& ?%?GS?%GS& ? %s'

    bind index,pager \CJ sidebar-next
    bind index,pager \CK sidebar-prev
    bind index,pager \CL sidebar-open

    bind  index       <Return> display-message
    bind  index,pager R        group-reply
    bind  index,pager @        compose-to-sender

    macro index \\ "<vfolder-from-query>"
    macro index,pager A "<modify-tags-then-hide>-unread -inbox\n<sync-mailbox>"
    bind index,pager + entire-thread
    bind index,pager y modify-tags
    bind index,pager X change-vfolder

    macro index,pager dd "<modify-tags-then-hide>deleted\n<sync-mailbox>" "notmuch 'kill' message"

    ignore *
    unignore from date subject to cc bcc tags
  '';

  home.file.".mailcap".text = ''
    text/html;${pkgs.w3m}/bin/w3m -dump -o document_charset=%{charset} '%s'; nametemplate=%s.html; copiousoutput
    image/*;${pkgs.imv}/bin/imv %s &>/dev/null &;
    application/pdf;${pkgs.zathura}/bin/zathura %s &>/dev/null &;
    image/pdf;${pkgs.zathura}/bin/zathura %s &>/dev/null &;
  '';

  accounts.email = {
    maildirBasePath = "";
    accounts = {
      "vkleen" = {
        neomutt = {
          sendMailCommand = "${sendMailCommand}/bin/sendmail";
        };
        folders = {
          inbox = "inbox";
          sent = "sent";
          drafts = "drafts";
          trash = "trash";
        };
        notmuch.enable = true;
        primary = true;
        address = "viktor@kleen.org";
        aliases = [ "kleen@usc.edu" "viktor.kleen@uni-due.de" "yasc@yasc.org" "vkleen@17220103.de" "viktor.kleen@tweag.io" ];
        realName = "Viktor Kleen";
        maildir = { path = "mail"; };
        gpg = {
          key = "1FE9015A0610E43C74EFC813744138390330BB39";
          signByDefault = true;
        };
      };
    };
  };

  home.file.".notmuch-config".text = ''
    [database]
    path=${config.home.homeDirectory}/mail

    [user]
    name=${account.realName}
    primary_email=${account.address}
    other_email=${builtins.concatStringsSep ";" account.aliases}

    [new]
    tags=unread;inbox;
    ignore=

    [search]
    exclude_tags=deleted;spam;

    [maildir]
    synchronize_flags=true

    [crypto]
    gpg_path=${pkgs.gnupg}/bin/gpg2
  '';

  home.activation = {
    writeDotForward = lib.hm.dag.entryAfter ["writeBoundary"] ''
      cat >${config.home.homeDirectory}/.forward <<EOF
      | ${new-mail}/bin/new-mail
      EOF
    '';
  };
}

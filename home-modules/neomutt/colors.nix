{ pkgs, config, ... }:
{
  home.file."${config.xdg.configHome}/neomutt/colors-selenized".text = ''
    color   normal            default         default
    color   index_number      brightblack     default
    color   index_date        magenta         default
    color   index_flags       yellow          default        .
    color   index_collapsed   cyan            default
    color   index             green           default        ~N
    color   index             green           default        ~v~(~N)
    color   index             red             default        ~F
    color   index             cyan            default        ~T
    color   index             blue            default        ~D
    color   index_label       brightred       default
    color   index_tags        red             default
    color   index_tag         brightmagenta   default        "encrypted"
    color   index_tag         brightgreen     default        "signed"
    color   index_tag         yellow          default        "attachment"
    color   body              brightwhite     default        ([a-zA-Z\+]+)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+ # urls
    color   body              green           default        [\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+ # mail addresses
    color   attachment        yellow          default
    color   signature         green           default
    color   search            brightred       black

    color   indicator         cyan            brightblack
    color   error             brightred       default
    color   status            brightcyan      default
    color   tree              brightcyan      brightblack
    color   tilde             cyan            default
    color   progress          white           default

    color  sidebar_indicator  cyan            default
    color  sidebar_highlight  cyan            brightblack
    color  sidebar_divider    brightblack     default
    color  sidebar_flagged    red             default
    color  sidebar_new        green           default

    color   hdrdefault        color81         default
    color   header            green           default        "^Subject: .*"
    color   header            yellow          default        "^Date: .*"
    color   header            red             default        "^Tags: .*"

    color   quoted            color60         default
    color   quoted1           yellow          default

    color   body              brightgreen     default        "Good signature from.*"
    color   body              green           default        "Fingerprint:( [A-Z0-9]{4}){5} ( [A-Z0-9]{4}){5}"
    color   body              brightred       default        "Bad signature from.*"
    color   body              brightred       default        "Note: This key has expired!"
    color   body              brightmagenta   default        "Problem signature from.*"
    color   body              brightmagenta   default        "WARNING: .*"
  '';
}

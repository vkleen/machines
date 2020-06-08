self: pkgs: with pkgs; let
  wrapperDir = "/run/wrappers/bin"; # HACK: this shouldn't be hard-coded
in {
  uucp = uucp.overrideAttrs (_: {
    configureFlags = "--with-newconfigdir=/etc/uucp";
    patches = [
      (pkgs.writeText "mailprogram" ''
         policy.h | 2 +-
         1 file changed, 1 insertion(+), 1 deletion(-)

        diff --git a/policy.h b/policy.h
        index 5afe34b..8e92c8b 100644
        --- a/policy.h
        +++ b/policy.h
        @@ -240,7 +240,7 @@
            the sendmail choice below.  Otherwise, select one of the other
            choices as appropriate.  */
         #if 1
        -#define MAIL_PROGRAM "/usr/lib/sendmail -t"
        +#define MAIL_PROGRAM "${wrapperDir}/sendmail -t"
         /* #define MAIL_PROGRAM "/usr/sbin/sendmail -t" */
         #define MAIL_PROGRAM_TO_BODY 1
         #define MAIL_PROGRAM_SUBJECT_BODY 1
      '')
    ];
  });
  rmail = pkgs.writeScriptBin "rmail" ''
      #!${pkgs.stdenv.shell}

      # Dummy UUCP rmail command for postfix/qmail systems

      IFS=" " read junk from junk junk junk junk junk junk junk relay

      case "$from" in
        *[@!]*) ;;
        *) from="$from@$relay";;
      esac

      exec ${wrapperDir}/sendmail -G -i -f "$from" -- "$@"
    '';
}

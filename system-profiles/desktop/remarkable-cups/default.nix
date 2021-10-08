{ pkgs, ...}:
let
  cloudUrl = "https://remarkable.kleen.org";

  remarkable-cups-backend = 
    pkgs.stdenv.mkDerivation {
      name = "remarkable-cups";
      CUPS_DATADIR = "${pkgs.cups}/share/cups";
      nativeBuildInputs = [ pkgs.cups ];
      unpackPhase = ":";
      installPhase = ":";
      buildPhase = ''
        mkdir -p $out/share/cups/model $out/lib/cups/backend

        ppdc -d $out/share/cups/model ${./remarkable.ppd.src}

        substitute ${./remarkable.sh} $out/lib/cups/backend/remarkable \
          --replace "@RMAPI@" "${pkgs.rmapi}/bin/rmapi" \
          --replace "@shell@" "${pkgs.runtimeShell}" \
          --replace "@cloudUrl@" "${cloudUrl}" \
          --replace "@date@" "${pkgs.coreutils}/bin/date" \
          --replace "@tr@" "${pkgs.coreutils}/bin/tr" \
          --replace "@cut@" "${pkgs.coreutils}/bin/cut" \
          --replace "@rm@" "${pkgs.coreutils}/bin/rm" \
          --replace "@id@" "${pkgs.coreutils}/bin/id" \
          --replace "@cat@" "${pkgs.coreutils}/bin/cat" \
          --replace "@sed@" "${pkgs.gnused}/bin/sed" \
          --replace "@RMAPI_CONFIG@" "/run/secrets/cups/rmapi"

        chmod a+x $out/lib/cups/backend/remarkable
      '';
    };
in {
  services.printing.drivers = [ remarkable-cups-backend ];
  age.secrets."cups/rmapi" = {
    file = ../../../secrets/rmfakecloud/rmapi.age;
    owner = "cups";
  };

  hardware.printers.ensurePrinters = [
    {
      name = "remarkable";
      deviceUri = "remarkable:/print";
      model = "remarkable.ppd";
    }
  ];
}

{ pkgs, config, ... }:
let
  cloudUrl = "https://remarkable.kleen.org";

  rmapi-wrapped = pkgs.symlinkJoin {
    name = "rmapi-wrapped";
    paths = [ pkgs.rmapi ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/rmapi \
        --set RMAPI_HOST "${cloudUrl}" \
        --set RMAPI_CONFIG "${config.age.secrets.rmapi.path}"
    '';
  };
in
{
  age.secrets."rmapi" = {
    rekeyFile = ../../secrets/rmapi.age;
    owner = "vkleen";
  };

  environment.systemPackages = [
    rmapi-wrapped
  ];
}

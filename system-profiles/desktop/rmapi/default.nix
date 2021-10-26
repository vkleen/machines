{ pkgs, ... }:
let
  cloudUrl = "https://remarkable.kleen.org";

  rmapi-wrapped = pkgs.symlinkJoin {
    name = "rmapi-wrapped";
    paths = [ pkgs.rmapi ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/rmapi \
        --set RMAPI_HOST "${cloudUrl}" \
        --set RMAPI_CONFIG /run/secrets/rmapi
    '';
  };
in {
  age.secrets."rmapi" = {
    file = ../../../secrets/rmfakecloud/rmapi.age;
    owner = "vkleen";
  };

  environment.systemPackages = [
    rmapi-wrapped
    pkgs.rmrl
    (pkgs.paper2remarkable.override { rmapi = rmapi-wrapped; })
  ];
}

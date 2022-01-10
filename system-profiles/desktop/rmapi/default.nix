{ pkgs, config, flake, ... }:
let
  cloudUrl = "https://remarkable.kleen.org";

  rmapi-wrapped = pkgs.symlinkJoin {
    name = "rmapi-wrapped";
    paths = [ pkgs.rmapi ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/rmapi \
        --set RMAPI_HOST "${cloudUrl}" \
        --set RMAPI_CONFIG /run/agenix/rmapi
    '';
  };
in {
  age.secrets."rmapi" = {
    file = ../../../secrets/rmfakecloud/rmapi.age;
    owner = "vkleen";
  };

  environment.systemPackages = [
    rmapi-wrapped
    flake.inputs.rmrl.packages.${config.nixpkgs.system}.rmrl
    #(pkgs.paper2remarkable.override { rmapi = rmapi-wrapped; })
  ];
}

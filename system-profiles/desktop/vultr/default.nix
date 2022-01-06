{ pkgs, ... }:
let

  vultr-wrapped = pkgs.symlinkJoin {
    name = "vultr-wrapped";
    paths = [ pkgs.vultr-cli ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vultr-cli \
        --add-flags --config --add-flags /run/agenix/vultr.yaml
    '';
  };
in {
  age.secrets."vultr.yaml" = {
    file = ../../../secrets/vultr.age;
    owner = "vkleen";
  };

  environment.systemPackages = [
    vultr-wrapped
  ];
}

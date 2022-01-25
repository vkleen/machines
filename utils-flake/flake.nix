{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
  };

  outputs = { self, ... }@inputs: {
    lib = import ./. { inherit (inputs.nixpkgs) lib; };
  };
}

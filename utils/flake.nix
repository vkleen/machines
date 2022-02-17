{
  outputs = { self, nixpkgs, ... }@inputs: {
    lib = import ./. { inherit (inputs.nixpkgs) lib; };
  };
}

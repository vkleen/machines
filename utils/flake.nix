{
  outputs = { self, nixpkgs, macname, ... }@inputs: {
    lib = import ./. { inherit (inputs.nixpkgs) lib; inherit macname; };
  };
}

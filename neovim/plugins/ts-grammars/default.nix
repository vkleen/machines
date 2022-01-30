{ lib, stdenv, tree-sitter, fetchgit, callPackage }:

let
  fetchGrammar = (v: fetchgit { inherit (v) url rev sha256 fetchSubmodules; });
  builtGrammars = let
    buildGrammar = name: grammar:
      callPackage ./grammar.nix {
        language = name;
        version = tree-sitter.version;
        source = fetchGrammar grammar;
        location = grammar.location or null;
        abiVersion = (import ./grammars/abi-version.nix).abi-version;
        generateFromGrammar = grammar.generateFromGrammar or false;
      };

    grammars' = (import ./grammars);
    grammars = (lib.makeExtensible (_: grammars')).extend (lib.composeManyExtensions [
      grammarsOverrides
      generateOverrides
    ]);

    grammarsOverrides = final: prev: {
      tree-sitter-ocaml_interface = prev.tree-sitter-ocaml // { location = "interface"; };
      tree-sitter-ocaml = prev.tree-sitter-ocaml // { location = "ocaml"; };
      tree-sitter-tsx = prev.tree-sitter-typescript // { location = "tsx"; };
      tree-sitter-typescript = prev.tree-sitter-typescript // { location = "typescript"; };
    };
    generateOverrides = final: prev:
      lib.listToAttrs (builtins.map (n: lib.nameValuePair "tree-sitter-${n}" (prev."tree-sitter-${n}" // { generateFromGrammar = true; })) [
        "d"
        "devicetree"
        "godot_resource"
        "ocamllex"
        "swift"
        "teal"
      ]);
  in lib.mapAttrs' (n: v: lib.nameValuePair (lib.strings.removePrefix "tree-sitter-" n) (buildGrammar n v))
                   (lib.filterAttrs (n: _: ! lib.elem n [ "__unfix__" "extend" ]) grammars);
in { inherit builtGrammars; }

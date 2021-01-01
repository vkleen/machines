{ lib }:
rec {
  inherit (builtins) readDir;
  inherit (lib) filterAttrs hasSuffix removeSuffix mapAttrs' nameValuePair isFunction functionArgs setFunctionArgs id;
  mapFilterAttrs = seive: f: attrs: filterAttrs seive (mapAttrs' f attrs);
  recImport = { dir, _import ? name: _base: import "${toString dir}/${name}" }:
    mapFilterAttrs
      (_: v: v != null)
      (n: v:
        if n != "default.nix" && hasSuffix ".nix" n && v == "regular"
        then
          let name = removeSuffix ".nix" n; in nameValuePair (name) (_import n name)
        else
          if v == "directory"
          then
            nameValuePair n (_import n n)
          else
            nameValuePair ("") (null))
      (readDir dir);

  types.attrNameSet = attr:
    let
      elemType = lib.types.enum (builtins.attrNames attr);
    in lib.types.mkOptionType rec {
      name = "attrNameSet";
      description = "set of names taken from an attribute set";
      check = lib.isList;
      emptyValue = { value = {}; };
      getSubOptions = prefix: elemType.getSubOptions (prefix ++ ["*"]);
      getSubModules = elemType.getSubModules;
      substSubModules = m: lib.types.listOf (elemType.substSubModules m);
      functor = (lib.types.defaultFunctor name) // { wrapped = elemType; };
      merge = loc: defs: map (x: x.value) (lib.lists.filter (x: x ? value) (lib.lists.unique (lib.lists.concatLists (lib.lists.imap1 (n: def:
        lib.lists.imap1 (m: def':
          (lib.modules.mergeDefinitions
            (loc ++ ["[definition ${toString n}-entry ${toString m}]"])
            elemType
            [{ inherit (def) file; value = def'; }]
          ).optionalValue
        ) def.value
      ) defs))));
    };

  overrideModuleArgs =
    let
      overrideModuleArgs = module: appOverride: if isFunction module then overrideModuleArgs' module appOverride else module;
      overrideModuleArgs' = module: appOverride: setFunctionArgs (inputs: overrideModuleArgs (module (appOverride inputs)) id) (functionArgs module);
    in overrideModuleArgs;

  overrideModuleOutput =
    let
      overrideModuleOutput = module: appOverride: if isFunction module then overrideModuleOutput' module appOverride else appOverride module;
      overrideModuleOutput' = module: appOverride: setFunctionArgs (inputs: overrideModuleOutput (module inputs) appOverride) (functionArgs module);
    in overrideModuleOutput;

  overrideModule = module: appInput: appOutput: overrideModuleOutput (overrideModuleArgs module appInput) appOutput;
}

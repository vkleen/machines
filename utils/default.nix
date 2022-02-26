{ lib, macname, allSystems ? [ "x86_64-linux" "aarch64-linux" ] }: let
in rec {
  inherit (builtins)
    readDir
    fromJSON;
  inherit (lib)
    attrNames
    attrValues
    concatMap
    elem
    extends
    fakeHash
    filterAttrs
    functionArgs
    genAttrs
    getAttrs
    getBin
    hasSuffix
    id
    isDerivation
    isFunction
    makeExtensible
    mapAttrs
    mapAttrs'
    nameValuePair
    optional
    optionalAttrs
    readFile
    removeSuffix
    setFunctionArgs
    strings
    trivial
    lists
    ;
  ints = import ./ints.nix { inherit lib; };

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


  inherit allSystems;
  forAllSystems = genAttrs allSystems;

  onlySystems = systems: overlay:
    final: prev: optionalAttrs (elem prev.stdenv.targetPlatform.system systems) (overlay final prev);
  
  forSystemsOverlay = defaultOverlay: overlays: final: prev: (overlays."${prev.stdenv.targetPlatform.system}" or defaultOverlay) final prev;

  elemAtOr = def: xs: n:
    if n >= lists.length xs
    then def
    else lists.elemAt xs n;

  private_address = linkId: machine_id: let
    inherit (strings) substring;
    inherit (ints) hexToInt;
    chars12 = substring 0 2 machine_id;
    chars34 = substring 2 2 machine_id;

    octet1 = hexToInt chars12;
    octet2 = hexToInt chars34;
  in assert 0 <= linkId && linkId <= 255;
    "10.${builtins.toString linkId}.${builtins.toString octet1}.${builtins.toString octet2}";

  linkLocal_address = linkId: hostName: let
    n = macname.elementTable.${hostName};
  in assert 0 <= linkId && linkId <= 255; "169.254.${builtins.toString linkId}.${builtins.toString n}";

  private_address6 = linkId: machine_id: let
    inherit (strings) substring;
    linkIdParts = trivial.toBaseDigits (ints.pow 2 16) linkId;
    linkId0-15  = strings.toLower (trivial.toHexString (elemAtOr 0 linkIdParts 0));
    linkId16-31 = strings.toLower (trivial.toHexString (elemAtOr 0 linkIdParts 1));
    linkId32-47 = strings.toLower (trivial.toHexString (elemAtOr 0 linkIdParts 2));

    chars1234 = substring 0 4 machine_id;
    chars5678 = substring 4 4 machine_id;
  in assert 0 <= linkId && linkId <= ints.pow 2 48;
    "fe80:3e0e:b7ec:${linkId0-15}:${linkId16-31}:${linkId32-47}:${chars1234}:${chars5678}";
}

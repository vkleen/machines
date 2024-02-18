{ ... }:
final: prev: {
  glog = prev.glog.overrideAttrs (o: {
    env.GTEST_FILTER =
      let
        oldFiltered = if o.env.GTEST_FILTER == "-" then [ ] else [ (builtins.substring 1 - 1 o.env.GTEST_FILTER) ];
        newFiltered = [
          "Symbolize.SymbolizeStackConsumption"
          "Symbolize.SymbolizeWithDemanglingStackConsumption"
        ];
      in
      "-${builtins.concatStringsSep ":" (oldFiltered ++ newFiltered)}";
  });
}

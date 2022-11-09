final: prev: {
  frr = prev.frr.overrideAttrs (o: rec {
    pname = "frr";
    version = "8.2.2";

    src = final.fetchFromGitHub {
      owner = "FRRouting";
      repo = pname;
      rev = "${pname}-${version}";
      hash = "sha256-zuOgbRxyyhFdBplH/K1fpyD+KUWa7FXPDmGKF5Kb7SQ=";
    };
    patches = (o.patches or []) ++ [
      ./patches/disable_sys_admin.patch
    ];
  });
}

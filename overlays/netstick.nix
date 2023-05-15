final: prev: {
  netstick = final.stdenv.mkDerivation {
    pname = "netstick";
    version = "git";
    nativeBuildInputs = [ final.cmake ];
    src = final.fetchFromGitHub {
      owner = "moslevin";
      repo = "netstick";
      rev = "274d510f6b058f1eeec13c3c586a891e8c4b75a4";
      hash = "sha256-+sI2jnkksrnoOzX621mLpLi19b3mmz3H63AIJSzuXOI=";
    };

    env.NIX_CFLAGS_COMPILE = "-Wno-error=stringop-truncation";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      install -m755 netstick netstickd $out/bin
      runHook postInstall
    '';
  };
}

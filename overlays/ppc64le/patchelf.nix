final: prev: {
  patchelfUnstable =
    if !final.stdenv.hostPlatform.isPower64 then prev.patchelfUnstable else
    prev.patchelfUnstable.overrideAttrs (o: {
      version = "unstable-vkleen";
      src = final.fetchFromGitHub {
        owner = "vkleen";
        repo = "patchelf";
        rev = "72f5529c3bc109204e0f250b1666afb9c8436f9f";
        sha256 = "sha256-lhvkU32OnmeKQ74hsCHlPd5SnJAgv9j6hWujS8Q3plU=";
      };
    });
}

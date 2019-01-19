self: pkgs: {
  solvespace = pkgs.solvespace.overrideAttrs (old: rec {
    name = "solvespace-2.3-20180510";
    rev = "2b9ffd15424eb95a21db6e6ca35339b3d9372b2e";
    src = pkgs.fetchgit {
      url = https://github.com/solvespace/solvespace;
      inherit rev;
      sha256 = "0hslqkck7aila4m6c5k42mdsz5si3wq0pfw6qn4v2psn529d43lx";
      fetchSubmodules = true;
    };
    buildInputs = old.buildInputs ++ [
      self.libspnav self.libxkbcommon self.epoxy self.at-spi2-atk self.at-spi2-core self.dbus
    ];
    preConfigure = ''
      patch CMakeLists.txt <<EOF
      @@ -20,9 +20,9 @@
       # NOTE TO PACKAGERS: The embedded git commit hash is critical for rapid bug triage when the builds
       # can come from a variety of sources. If you are mirroring the sources or otherwise build when
       # the .git directory is not present, please comment the following line:
      -include(GetGitCommitHash)
      +# include(GetGitCommitHash)
       # and instead uncomment the following, adding the complete git hash of the checkout you are using:
      -# set(GIT_COMMIT_HASH 0000000000000000000000000000000000000000)
      +set(GIT_COMMIT_HASH $rev)
      EOF
    '';
  });
}

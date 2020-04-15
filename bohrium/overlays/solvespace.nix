self: pkgs: {
  solvespace = pkgs.solvespace.overrideAttrs (old: rec {
    name = "solvespace-2.3-20190818";
    rev = "97c8cb7d710aeca59cf691259e9d0cdefb103e51";
    src = pkgs.fetchgit {
      url = https://github.com/solvespace/solvespace;
      inherit rev;
      sha256 = "0hwnvb2ywh8r39fn0lbakp06y7i4hzqysglgnia2armmqwg8y1g5";
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

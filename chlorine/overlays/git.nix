self: super: {
  git = super.git.overrideAttrs (o: {
    doInstallCheck = false;
  });
}

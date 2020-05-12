self: super: {
  bash-completion = super.bash-completion.overrideAttrs (_: {
    doCheck = false;
  });
}

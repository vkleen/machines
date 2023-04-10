{
  services.openssh = {
    enable = true;
    settings = {
      passwordAuthentication = false;
    };
  };
}

flake:
{ ... }:
{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
}

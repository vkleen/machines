{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-dymo pkgs.hplip ];
  };
}

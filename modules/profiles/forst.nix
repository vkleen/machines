{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    stateless = true;
  };
  hardware.printers.ensureDefaultPrinter = "forst";
  hardware.printers.ensurePrinters = [
    {
      name = "forst";
      deviceUri = "ipp://forst.forstheim.kleen.org:443/ipp";
      model = "everywhere";
      ppdOptions = {
        PageSize = "A4";
        Duplex = "DuplexNoTumble";
      };
    }
  ];
}

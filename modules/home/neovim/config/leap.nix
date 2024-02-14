{ ... }:
{
  programs.nixvim = {
    plugins.leap = {
      enable = true;
      addDefaultMappings = true;
    };
  };
}

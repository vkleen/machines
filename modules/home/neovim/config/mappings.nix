{ ... }:
{
  programs.nixvim.keymaps = [
    {
      key = "^";
      action = "q";
      options = {
        desc = "Define a macro";
        noremap = true;
      };
    }
    {
      key = "q";
      action = "b";
      options.desc = "previous word";
    }
    {
      key = "Q";
      action = "B";
      options.desc = "previous WORD";
    }
  ];
}

{ config, pkgs, lib, ... }:
{
  programs.nixvim = {
    globals.mapleader = " ";
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    options = {
      shell = lib.getExe pkgs.bash;

      mouse = "a";
      encoding = "utf-8";
      fileencoding = "utf-8";
      updatetime = 100;

      undofile = true;
      undodir = config.nixvim.helpers.mkRaw ''vim.fn.stdpath("state") .. "/undo/"'';

      backup = true;
      backupdir = config.nixvim.helpers.mkRaw ''vim.fn.stdpath("state") .. "/backup/"'';

      swapfile = true;
      directory = config.nixvim.helpers.mkRaw ''vim.fn.stdpath("state") .. "/swap/"'';

      backspace = "indent,eol,start";

      hidden = true;

      number = true;

      signcolumn = "yes";

      showcmd = true;

      smarttab = true;
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      shiftround = true;

      expandtab = true;

      autoindent = true;
      smartindent = true;

      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;
      magic = true;

      ttyfast = true;

      grepprg = "${lib.getExe pkgs.ripgrep} --vimgrep --no-heading";
      grepformat = "%f:%l:%c:%m,%f:%l:%m";

      showmatch = true;

      splitright = true;
      splitbelow = true;

      completeopt = [ "menuone" "noselect" "noinsert" ];

      backupcopy = "yes";

      exrc = true;

      fillchars = {
        horiz = "━";
        horizup = "┻";
        horizdown = "┳";
        vert = "┃";
        vertleft = "┫";
        vertright = "┣";
        verthoriz = "╋";
        fold = " ";
        eob = " ";
        msgsep = "‾";
      };
    };
  };
}

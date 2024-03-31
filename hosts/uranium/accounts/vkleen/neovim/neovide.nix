{ ... }:
{
  home.packages = [
    # llvm 16 crashes while compiling libskia...
    #pkgs.neovide
  ];

  programs.nixvim.extraConfigLua = /*lua*/ ''
    if vim.g.neovide then
      vim.g.neovide_floating_blur = false
      vim.g.neovide_floating_opacity = 0.9
      vim.g.neovide_remember_window_size = false
      vim.opt.guifont = "PragmataPro Mono Liga,Noto Color Emoji:h12"
    end
  '';
}

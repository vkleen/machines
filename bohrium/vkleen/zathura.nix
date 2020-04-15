{pkgs, ...}:
{
  home.packages = [
    (pkgs.zathura.override { useMupdf = false; })
  ];
}

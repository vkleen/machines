{ ... }:
{
  users.users.vkleen = {
    group = "users";
    extraGroups = [ "wheel" "docker" ];
    createHome = true;
    home = "/home/vkleen";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAID4bSfqKF8Hw7SUoA+MEogjSXoqPbmqdud8LfKYbVA6UAAAABHNzaDo= vkleen@bohrium"
    ];
    uid = 1000;
    hashedPassword = "$6$rounds=500000$SmVIMOyBMt$2zWfkdOjlH/OnYQZb/Ix3RUuGl1QGexOyaFuu.KCIuYpw1uhXekpQATgQCkOsKtroxY13eAbiLE8z.cp3jUpo.";
  };
  environment.pathsToLink = [ "/share/zsh" ];
  home-manager.users.vkleen = {
    home.stateVersion = "23.05";
  };
}

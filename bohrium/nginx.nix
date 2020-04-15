{ config, pkgs, ... }:
{
  services.nginx = let cfg = config; in rec {
    enable = false;
    stateDir = "/tmp/${toString cfg.users.extraUsers.${user}.uid}/nginx";
    user = "vkleen";
    group = "users";
    config = ''
      events {
      }
      http {
        upstream docsgl {
          server unix:/tmp/${toString cfg.users.extraUsers.${user}.uid}/nginx/docs.gl.socket;
          server docs.gl backup;
        }
        server {
          listen 127.0.0.1:80;
          listen [::1]:80;
          server_name docs.gl.local;
          location / {
            proxy_pass http://docsgl;
            proxy_set_header Host docs.gl;
          }
        }
        server {
          listen 127.0.0.1:80;
          listen [::1]:80;
          server_name ~(?<domain>.+)\.hoogle;
          location / {
            proxy_pass http://unix:/tmp/${toString cfg.users.extraUsers.${user}.uid}/nginx/hoogle.$domain.socket;
          }
        }
      }
    '';
  };
}

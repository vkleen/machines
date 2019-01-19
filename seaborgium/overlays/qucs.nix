self: pkgs: rec {
  adms = pkgs.stdenv.mkDerivation {
    name = "adms";
    src = pkgs.fetchgit {
      url = "https://github.com/Qucs/ADMS.git";
      rev = "e24d007810038a81ed90d98ffcfc6542ef8757f5";
      sha256 = "1pcwq5khzdq4x33lid9hq967gv78dr5i4f2sk8m8rwkfqb9vdzrg";
    };
    configureFlags = [ "--enable-maintainer-mode" ];
    preConfigure = ''
      sh ./bootstrap.sh
    '';
    buildInputs = with pkgs; [
      flex bison libtool autoconf automake perl perlPackages.XMLLibXML
    ];
  };

  qucs-dev = pkgs.qucs.overrideAttrs (attrs: {
    name = "qucs-dev";
    src = pkgs.fetchgit {
      url = "https://github.com/Qucs/qucs.git";
      rev = "5896b2480fc3eef7ad76780f053df7f7f01b24d4";
      sha256 = "12y1gygz5wkg8s0ig7bvivbvxhjga9fcqxwz0w54x43nz7fqvr66";
    };
    configureFlags = [ "--disable-doc" ];
    preConfigure = ''
      sh ./bootstrap
    '';

    buildInputs = attrs.buildInputs ++ (with pkgs; [
      autoconf automake libtool git gperf adms
    ]);
  });
}

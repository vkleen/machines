self: super: {
  arduino-cli =
    let src = self.fetchFromGitHub {
          owner = "arduino";
          repo = "arduino-cli";
          rev = "e55662591785b0eecbf61461cd0544319836a786";
          sha256 = "0ck5i00fy57hclc4r6n1xpahk8jgy3sg1nldvkh48khmkgnzps9q";
        } // { branch = "master"; };
    in self.callPackage ./arduino-cli { arduino-cli = src; };
}

{ ... }:
final: prev:
{
  pragmasevka-nonerd = final.iosevka.override {
    set = "pragmasevka";
    privateBuildPlan = {
      family = "Pragmasevka";
      spacing = "term";
      serifs = "sans";
      noCvSs = true;
      exportGlyphNames = true;
      hintParams = [ "-a" "qqq" ];
      widths.normal = {
        shape = 500;
        menu = 5;
        css = "normal";
      };
      metricOverride = {
        leading = 1100;
        xHeight = 550;
      };
      ligations = {
        inherits = "dlig";
      };
      variants = {
        inherits = "ss08";
      };
      weights = {
        regular = {
          shape = 425;
          menu = 400;
          css = 400;
        };
        semibold = {
          shape = 600;
          menu = 600;
          css = 600;
        };
        bold = {
          shape = 800;
          menu = 700;
          css = 700;
        };
        black = {
          shape = 900;
          menu = 900;
          css = 900;
        };
      };
      slopes = {
        upright = "default.Upright";
        italic = "default.Italic";
      };
    };
  };
  pragmasevka = final.runCommand "pragmasevka"
    {
      src = final.pragmasevka-nonerd;
      nativeBuildInputs = [ final.nerd-font-patcher ];
    } ''
    for f in $src/share/fonts/truetype/*; do
      nerd-font-patcher $f --complete --no-progressbars --outputdir build
    done

    mkdir -p $out/share/fonts/truetype
    install -Dm 444 build/* $out/share/fonts/truetype
    install -Dm 444 $src/share/fonts/truetype/* $out/share/fonts/truetype
  '';
}

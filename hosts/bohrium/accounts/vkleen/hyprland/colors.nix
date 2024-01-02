{ hash ? true }:
let
  added_hash = if hash then "#" else "";
in {
    bg = "${added_hash}103c48";
    black = "${added_hash}184956";
    br_black = "${added_hash}2d5b69";

    white = "${added_hash}72898f";
    fg = "${added_hash}adbcbc";
    br_white = "${added_hash}cad8d9";

    red = "${added_hash}fa5750";
    green = "${added_hash}75b938";
    yellow = "${added_hash}dbb32d";
    blue = "${added_hash}4695f7";
    magenta = "${added_hash}f275be";
    cyan = "${added_hash}41c7b9";
    orange = "${added_hash}ed8649";
    violet = "${added_hash}af88eb";

    br_red = "${added_hash}ff665c";
    br_green = "${added_hash}84c747";
    br_yellow = "${added_hash}ebc13d";
    br_blue = "${added_hash}58a3ff";
    br_magenta = "${added_hash}ff84cd";
    br_cyan = "${added_hash}53d6c7";
    br_orange = "${added_hash}fd9456";
    br_violet = "${added_hash}bd96fa";
  }

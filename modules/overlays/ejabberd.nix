{ ... }:
final: prev: {
  ejabberd = prev.ejabberd.override { erlang = final.erlang_27; };
}

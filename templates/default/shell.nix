{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    # ...
  ];

  name = "";

  shellHook = ''
    exec zsh
  '';
}

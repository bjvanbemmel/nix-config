{ pkgs ? import <nixpkgs> {} }:

let
  pyfirmata2 = pkgs.python3Packages.buildPythonPackage rec {
    name = "pyFirmata2";
    version = "2.5.0";

    src = pkgs.fetchPypi {
      pname = name;
      version = version;
      hash = "sha256-kRSOTNsGQ/Ty8388A7g9geHUm/TwHw0JSoJHMENkofE=";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [ pyserial ];

    doCheck = false;
  };
in
pkgs.mkShell {
  buildInputs = with pkgs.python3Packages; [
    python
    pyfirmata2
  ];

  name = "embedded-py";

  shellHook = ''
    exec zsh
  '';
}

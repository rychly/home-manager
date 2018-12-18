{ pkgs ? import <nixpkgs> {} }:

rec {
  home-manager = pkgs.callPackage ./home-manager {
    path = toString ./.;
  };

  install = pkgs.callPackage ./home-manager/install.nix {
    inherit home-manager;
  };

  docs = import ./doc { inherit pkgs; };

  nixos = import ./nixos;
}

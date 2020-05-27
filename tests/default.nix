{ pkgs ? import <nixpkgs> {} }:

let

  lib = import ../modules/lib/stdlib-extended.nix pkgs.lib;

  nmt = pkgs.fetchFromGitLab {
    owner = "rycee";
    repo = "nmt";
    rev = "8e130d655ec396ce165763c95bbf4ac429810ca8";
    sha256 = "1jbljr06kg1ycdn24hj8xap16axq11rhb6hm4949fz48n57pwwps";
  };

  modules = import ../modules/modules.nix {
    inherit lib pkgs;
    check = false;
  } ++ [
    # Fix impurities. Without these some of the user's environment
    # will leak into the tests through `builtins.getEnv`.
    {
      xdg.enable = true;
      home.username = "hm-user";
      home.homeDirectory = "/home/hm-user";
    }
  ];

in

import nmt {
  inherit lib pkgs modules;
  testedAttrPath = [ "home" "activationPackage" ];
  tests = builtins.foldl' (a: b: a // (import b)) { } ([
    ./lib/types
    ./meta
    ./modules/files
    ./modules/home-environment
    ./modules/misc/fontconfig
    ./modules/programs/alacritty
    ./modules/programs/alot
    ./modules/programs/aria2
    ./modules/programs/bash
    ./modules/programs/browserpass
    ./modules/programs/dircolors
    ./modules/programs/fish
    ./modules/programs/git
    ./modules/programs/gpg
    ./modules/programs/i3status
    ./modules/programs/kakoune
    ./modules/programs/lf
    ./modules/programs/lieer
    ./modules/programs/mbsync
    ./modules/programs/neomutt
    ./modules/programs/newsboat
    ./modules/programs/qutebrowser
    ./modules/programs/readline
    ./modules/programs/ssh
    ./modules/programs/starship
    ./modules/programs/texlive
    ./modules/programs/tmux
    ./modules/programs/zsh
    ./modules/xresources
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    ./modules/misc/debug
    ./modules/misc/pam
    ./modules/misc/xdg
    ./modules/misc/xsession
    ./modules/programs/abook
    ./modules/programs/autorandr
    ./modules/programs/firefox
    ./modules/programs/getmail
    ./modules/services/lieer
    ./modules/programs/rofi
    ./modules/services/polybar
    ./modules/services/sxhkd
    ./modules/services/window-managers/i3
    ./modules/systemd
    ./modules/targets
  ]);
}

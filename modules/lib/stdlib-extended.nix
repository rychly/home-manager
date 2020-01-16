# Just a convenience function that returns the standard library from
# the given package set extended with the HM library.

pkgs:

let
  mkHmLib = import ./.;
in
  pkgs.lib.extend (self: super: {
    hm = mkHmLib { lib = super; };
  })

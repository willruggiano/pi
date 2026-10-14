{
  description = "Coding agent CLI with read, bash, edit, write tools and session management";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # nixpkgs unstable no longer supports Intel macOS. Keep using the final
    # Darwin branch that does so for pi's x86_64-darwin package.
    nixpkgs-darwin-x64.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-darwin-x64,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      eachSystem =
        f:
        lib.genAttrs systems (
          system:
          let
            pkgs = import (if system == "x86_64-darwin" then nixpkgs-darwin-x64 else nixpkgs) {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          in
          f pkgs
        );
    in
    {
      packages = eachSystem (pkgs: {
        default = pkgs.pi;
        inherit (pkgs) pi;
      });

      formatter = eachSystem (pkgs: pkgs.callPackage ./nix/treefmt.nix { });

      apps = eachSystem (pkgs: {
        default = {
          type = "app";
          program = lib.getExe pkgs.pi;
          meta.description = pkgs.pi.meta.description;
        };
      });

      overlays.default = _: prev: {
        pi = prev.callPackage ./nix/package.nix { platforms = systems; };
      };
    };
}

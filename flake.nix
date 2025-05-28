{
  description = "Basic Neovim configuration";

  # To easily generate a derivation per architecture
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      # We define first an overlay, i.e. a definition of new packages as recommended in
      # https://discourse.nixos.org/t/how-to-consume-a-eachdefaultsystem-flake-overlay/19420/9
      overlays.default = final: prev: {
        yourprogram = final.callPackage ({ stdenv, pkgs, ... }:
          # You can put here the derivation to build your program, for instance:
          stdenv.mkDerivation {
            src = ./.;
            pname = "tar_nvim";
            version = "unstable";
            buildInputs = with pkgs; [
              neovim

              ripgrep
              fd
              fzf
              tree
            ];
          }) { };
      };
    }
    // # We now add the package defined in the above overlay for all architectures
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          overlays = [ self.overlays.default ];
        };
      in {
        # Create a new package
        packages = {
          tar_nvim = pkgs.nvim;
          default =
            self.packages.${system}.tar_nvim; # default program: this way, typing "nix develop" will directly put you in a shell needed to develop the above your program, running "nix build/run" will directly build/run this program etc.
        };

        homeManagerModules.default = { config, lib, pkgs, ... }: {
          home = {
            file.".config/nvim" = {
              source = ./lua;
              recursive = true;
            };

            shellAliases = {
              vi = "nvim";
              vim = "nvim";
            };
          };
        };
      }));
}

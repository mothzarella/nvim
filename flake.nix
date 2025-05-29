{
  description = "Neovim with flakes";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        neovim-configured = pkgs.neovim.override { viAlias = true; };
      in {
        packages = {
          default = neovim-configured;
          neovim = neovim-configured;
        };

        apps = {
          default = {
            type = "app";
            program = "${pkgs.writeShellScript "nvim-with-local-config" ''
              exec ${neovim-configured}/bin/nvim --cmd "set runtimepath^=${
                ./.
              }/config" "$@"
            ''}";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            neovim-configured
            ripgrep
            fd
            fzf
            git
            gcc
            nodejs
            python3
          ];
        };
      });
}

{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      neovim
      neovim-remote

      # Use mason to install LSP
    ];
  };

  programs.neovim = {
    viAlias = true;
    vimAlias = true;
  };
}

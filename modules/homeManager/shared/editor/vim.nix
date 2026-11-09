{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-nix
    ];
  };

  programs.bash.shellAliases = {
    vi = "${pkgs.vim.outPath}/bin/vim";
    vim = "${pkgs.vim.outPath}/bin/vim";
  };
}

{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    plugins = [ ];
  };

  programs.bash.shellAliases = {
    vi = "${pkgs.vim.outPath}/bin/vim";
    vim = "${pkgs.vim.outPath}/bin/vim";
  };
}

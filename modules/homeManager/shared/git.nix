{ ... }:
{
  programs.git = {
    enable = true;
    userEmail = "h.bakardzhiev@gmx.com";
    userName = "hbakardzhiev";
    aliases = { };
  };
  programs.bash = {
    shellAliases = {
      gitnixos = "function myFunc() { cd /etc/nixos && git pull &&  git add . && git status && git commit -m [$1] && git push; }; myFunc";
    };
  };
}

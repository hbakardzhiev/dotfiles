{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "h.bakardzhiev@gmx.com";
        name = "hbakardzhiev";
      };
      alias = { };
      safe = {
        directory = "/etc/nixos";
      };
    };
  };
  programs.bash = {
    shellAliases = {
      gitnixos = "function myFunc() { cd /etc/nixos && git pull &&  git add . && git status && git commit -m [$1] && git push; }; myFunc";
    };
  };
}

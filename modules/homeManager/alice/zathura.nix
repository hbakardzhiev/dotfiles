{ ... }:
{
  programs.zathura = {
    enable = true;
    mappings =
      let
        recolor = "set recolor";
      in
      {
        "b" = "scroll full-up";
        # "<C-i>" = recolor;
        "I" = recolor;
        "т" = "scroll down";
        "н" = "scroll up";
      };
    options = {
      scroll-step = 200;
      selection-clipboard = "clipboard";
      # sandbox = "strict";
    };
  };
}

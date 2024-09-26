{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      marksman
      nil
      nodePackages.typescript-language-server
      omnisharp-roslyn
    ];
    settings = {
      theme = "dark_plus";
      editor = {
        mouse = true;
        bufferline = "always";
        color-modes = true;
        true-color = true;
        lsp.display-messages = true;
        lsp.display-inlay-hints = true;
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "file-encoding"
          ];
          center = [ "file-name" ];
        };
        soft-wrap = {
          enable = true;
          max-wrap = 25;
          max-indent-retain = 0;
          wrap-indicator = "";
        };
      };
      keys.normal = {
        space.space = "file_picker";
        esc = [
          "collapse_selection"
          "keep_primary_selection"
        ];
        C-s = [
          ":format"
          ":write"
        ];
        y = ":clipboard-yank-join";
        p = ":clipboard-paste-replace";
        q = ":buffer-close";
        d = [
          ":clipboard-yank-join"
          "delete_selection"
        ];
        V = [
          "extend_to_line_bounds"
          "select_mode"
        ];
        C-p = ":clipboard-paste-after";
      };
      keys.insert = {
        C-s = [
          ":format"
          ":write"
        ];
      };
      keys.select = {
        X = [
          "extend_line_up"
          "extend_to_line_bounds"
        ];
        x = [
          "extend_line_down"
          "extend_to_line_bounds"
        ];
        esc = [
          "normal_mode"
          "collapse_selection"
        ];
        y = [
          ":clipboard-yank-join"
          "normal_mode"
          "collapse_selection"
        ];
        d = [
          ":clipboard-yank-join"
          "delete_selection"
        ];
        p = ":clipboard-paste-replace";
        C-p = ":clipboard-paste-after";
      };
    };
  };
}

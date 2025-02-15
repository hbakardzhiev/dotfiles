{ pkgs, hostname, ... }:
let
  chosenTheme = "emacs";
in
{
  programs.helix = {
    languages = {
      language = [
        {
          name = "csv";
          file-types = [ "csv" ];
          scope = "source.csv";
        }
      ];
      grammar = [
        {
          name = "csv";
          source.git = "https://github.com/weartist/rainbow-csv-tree-sitter";
          source.rev = "896e6d09b23a1b0d87e45bf97ca34a249f41495c";
        }
      ];
    };

    themes = {
      "comment" = {
        fg = "firebrick";
      };
      "constant" = {
        fg = "dark_cyan";
      };
      "constant.builtin" = {
        fg = "dark_slate_blue";
      };
      "function" = {
        fg = "blue1";
      };
      "function.call" = {
        fg = "blue1";
      };
      "function.macro" = {
        fg = "dark_slate_blue";
      };
      "function.builtin" = {
        fg = "dark_slate_blue";
      };
      "function.special" = {
        fg = "dark_slate_blue";
      };
      "keyword" = {
        fg = "purple";
      };
      "operator" = {
        fg = "purple";
      };
      "punctuation" = {
        fg = "black";
      };
      "string" = {
        fg = "violetred4";
      };
      "string.special" = {
        fg = "violetred4";
        modifiers = [ "bold" ];
      };
      "type" = {
        fg = "forest_green";
      };
      "type.builtin" = {
        fg = "dark_slate_blue";
      };
      "constructor" = {
        fg = "forest_green";
      };
      "variable" = {
        fg = "sienna";
      };
      "variable.builtin" = {
        fg = "dark_slate_blue";
      };
      "variable.parameter" = {
        fg = "sienna";
      };
      "tag" = {
        fg = "blue1";
      };
      "label" = {
        fg = "dark_slate_blue";
      };
      "attribute" = {
        fg = "dark_slate_blue";
      };
      "namespace" = {
        fg = "dark_cyan";
      };
      "module" = {
        fg = "dark_cyan";
      };
      "special" = {
        fg = "blue1";
      };

      "markup.heading" = {
        fg = "gold";
        modifiers = [ "bold" ];
      };
      "markup.heading.marker" = {
        fg = "gray60";
      };
      "markup.heading.1" = {
        fg = "blue1";
      };
      "markup.heading.2" = {
        fg = "sienna";
      };
      "markup.heading.3" = {
        fg = "purple";
      };
      "markup.heading.4" = {
        fg = "firebrick";
      };
      "markup.heading.5" = {
        fg = "forest_green";
      };
      "markup.heading.6" = {
        fg = "dark_cyan";
      };
      "markup.list" = {
        fg = "black";
      };
      "markup.bold" = {
        modifiers = [ "bold" ];
      };
      "markup.italic" = {
        modifiers = [ "italic" ];
      };
      "markup.strikethrough" = {
        modifiers = [ "crossed_out" ];
      };
      "markup.link.url" = {
        fg = "royalblue3";
        modifiers = [ "underlined" ];
      };
      "markup.link.text" = {
        fg = "royalblue3";
      };
      "markup.quote" = {
        fg = "gray60";
      };
      "markup.raw.inline" = {
        fg = "dark_cyan";
      };
      "markup.raw.block" = {
        fg = "dark_cyan";
      };

      "ui.background" = {
        fg = "black";
        bg = "white";
      };
      "ui.background.separator" = {
        fg = "black";
        bg = "white";
      };
      "ui.cursor" = {
        fg = "white";
        bg = "gray70";
      };
      "ui.cursor.primary" = {
        fg = "white";
        bg = "black";
      };
      "ui.cursor.match" = {
        fg = "black";
        bg = "turquoise";
      };
      "ui.cursor.select" = {
        fg = "white";
        bg = "black";
      };
      "ui.cursor.insert" = {
        fg = "red";
        bg = "black";
      };
      "ui.linenr" = {
        fg = "gray60";
      };
      "ui.linenr.selected" = {
        fg = "gray80";
      };
      # "ui.statusline" = {
      #   fg = "black";
      #   bg = "gray75";
      # };
      # "ui.statusline.inactive" = {
      #   fg = "gray20";
      #   bg = "gray90";
      # };
      "ui.bufferline" = {
        fg = "gray36";
        bg = "gray90";
        modifiers = [ "underlined" ];
      };
      "ui.bufferline.active" = {
        fg = "gray0";
        bg = "gray99";
      };
      "ui.bufferline.background" = {
        bg = "gray75";
      };
      "ui.popup" = {
        fg = "black";
        bg = "gray97";
      };
      "ui.popup.info" = {
        fg = "black";
        bg = "gray97";
      };
      "ui.window" = {
        fg = "black";
      };
      "ui.help" = {
        fg = "dark_red";
        bg = "cornsilk";
      };
      "ui.text" = {
        fg = "black";
      };
      "ui.text.focus" = {
        fg = "black";
        bg = "darkseagreen2";
      };
      "ui.menu" = {
        fg = "black";
        bg = "cornsilk";
      };
      "ui.menu.selected" = {
        fg = "dark_red";
        bg = "light_blue";
      };
      "ui.selection" = {
        bg = "lightgoldenrod1";
      };
      "ui.selection.primary" = {
        bg = "lightgoldenrod2";
      };
      # Malformed ANSI: highlight. See 'https://github.com/helix-editor/helix/issues/5709'
      # "ui.virtual.whitespace" = "highlight";
      "ui.virtual.ruler" = {
        bg = "gray95";
      };
      "ui.virtual.inlay-hint" = {
        fg = "gray75";
      };
      "ui.cursorline.primary" = {
        bg = "darkseagreen2";
      };
      "ui.cursorline.secondary" = {
        bg = "darkseagreen2";
      };
      "ui.statusline" = {
        normal = {
          fg = "black";
          bg = "blue";
        }; # modifiers = ["bold"]; };
        insert = {
          fg = "black";
          bg = "darkseagreen2";
          modifiers = [ "bold" ];
        };
        select = {
          fg = "black";
          bg = "green";
          modifiers = [ "bold" ];
        };
      };

      "diff.plus" = {
        fg = "green3";
      };
      "diff.delta" = {
        fg = "orange2";
      };
      "diff.minus" = {
        fg = "red2";
      };

      "error" = {
        fg = "red1";
      };
      "warning" = {
        fg = "dark_orange";
      };
      "info" = {
        fg = "forest_green";
      };
      "hint" = {
        fg = "dark_cyan";
      };

      "diagnostic.error" = {
        underline = {
          color = "red1";
          style = "curl";
        };
      };
      "diagnostic.warning" = {
        underline = {
          color = "dark_orange";
          style = "curl";
        };
      };
      "diagnostic.info" = {
        underline = {
          color = "forest_green";
          style = "curl";
        };
      };
      "diagnostic.hint" = {
        underline = {
          color = "dark_cyan";
          style = "curl";
        };
      };
      "diagnostic.unnecessary" = {
        modifiers = [ "dim" ];
      };
      "diagnostic.deprecated" = {
        modifiers = [ "crossed_out" ];
      };
    };
    enable = true;
    defaultEditor = true;
    extraPackages =
      with pkgs;
      [
        marksman
        nil
      ]
      ++ lib.optionals (hostname == "alice") [
        # Note the \n for the newline char, in case there's one in /etc/hostname
        # intelephense
      ];
    settings = {
      theme = chosenTheme;
      editor = {
        mouse = true;
        bufferline = "always";
        color-modes = true;
        true-color = true;
        lsp.display-messages = true;
        lsp.display-inlay-hints = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "file-encoding"
          ];
          mode = {
            normal = "NORM 👀";
            insert = "INS 📝"; 
            select = "SEL 🪄";
          };
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
        C-g = [
          ":new"
          ":insert-output ${pkgs.lazygit}/bin/lazygit"
          ":buffer-close!"
          ":redraw"
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
        C-a = "select_all";
      };
      keys.insert = {
        C-s = [
          ":format"
          ":write"
        ];
        C-a = "select_all";
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
        C-a = "select_all";
      };
    };
  };
}

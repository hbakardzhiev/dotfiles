{ pkgs, hostname, ... }:
let
  chosenTheme = "myCustomTheme";
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
      "${chosenTheme}" = {
        "attribute" = { fg = "yellow"; };
        "label" = { fg = "cyan"; };
        "operator" = { fg = "red"; };
        "tag" = { fg = "cyan"; };
        "special" = { fg = "deep-purple"; };
        "property" = { fg = "purple"; };
        "constructor" = { fg = "blue"; };
        "namespace" = { fg = "blue"; };
        "module" = { fg = "blue"; };
        
        "type" = { fg = "gold"; };
        "type.builtin" = { fg = "yellow"; };
        "type.enum" = { fg = "cyan"; };
        "type.enum.variant" = { fg = "cyan"; };
        
        "constant" = { fg = "cyan"; modifiers = ["bold"]; };
        "constant.builtin" = { fg = "deep-purple"; };
        "constant.builtin.boolean" = { fg = "purple"; modifiers = ["bold"]; };
        "constant.character" = { fg = "green"; };
        "constant.character.escape" = { fg = "brown"; modifiers = ["bold"]; };
        "constant.numeric" = { fg = "brown"; modifiers = ["bold"]; };
        "constant.numeric.integer" = { fg = "brown"; modifiers = ["bold"]; };
        "constant.numeric.float" = { fg = "brown"; modifiers = ["bold"]; };
        
        "string" = { fg = "green"; };
        "string.regexp" = { fg = "purple"; };
        "string.special" = { fg = "green"; };
        "string.special.path" = { fg = "blue"; };
        "string.special.url" = { fg = "light-blue"; };
        "string.special.symbol" = { fg = "pink"; };
        
        "comment" = { fg = "grey"; modifiers = ["italic"]; };
        "comment.line" = { fg = "grey"; modifiers = ["italic"]; };
        "comment.block" = { fg = "grey"; modifiers = ["italic"]; };
        "comment.block.documentation" = { fg = "grey"; modifiers = ["italic"]; };

        "variable" = { fg = "magenta"; };
        "variable.builtin" = { fg = "light-blue"; };
        "variable.parameter" = { fg = "red"; };
        "variable.other" = { fg = "pink"; };
        "variable.other.member" = { fg = "pink"; };
        
        "punctuation" = { fg = "black"; };
        "punctuation.delimiter" = { fg = "purple"; };
        "punctuation.bracket" = { fg = "brown"; };
        "punctuation.special" = { fg = "brown"; };
        
        "keyword" = { fg = "purple"; };
        "keyword.control" = { fg = "purple"; };
        "keyword.control.conditional" = { fg = "red"; modifiers = ["bold"]; };
        "keyword.control.repeat" = { fg = "pink"; modifiers = ["bold"]; };
        "keyword.control.import" = { fg = "red"; };
        "keyword.control.return" = { fg = "deep-purple"; modifiers = ["bold"]; };
        "keyword.control.exception" = { fg = "purple"; };
        "keyword.operator" = { fg = "red"; };
        "keyword.directive" = { fg = "deep-purple"; };
        "keyword.function" = { fg = "purple"; };
        "keyword.storage" = { fg = "purple"; };
        "keyword.storage.type" = { fg = "purple"; };
        "keyword.storage.modifier" = { fg = "purple"; modifiers = ["bold"]; };
        
        "function" = { fg = "blue"; };
        "function.builtin" = { fg = "cyan"; };
        "function.method" = { fg = "light-blue"; };
        "function.macro" = { fg = "pink"; modifiers = ["bold"]; };
        "function.special" = { fg = "cyan"; };
        
        "markup.heading" = { fg = "red"; };
        "markup.heading.marker" = { fg = "red"; };
        "markup.heading.1" = { fg = "red"; modifiers = ["bold"]; };
        "markup.heading.2" = { 
          fg = "gold"; 
          modifiers = [
            "bold"
          ]; 
          underline = { style = "line"; }; 
        };
        "markup.heading.3" = { fg = "yellow"; modifiers = ["bold"]; };
        "markup.heading.4" = { fg = "green"; modifiers = ["bold"]; };
        "markup.heading.5" = { fg = "blue"; modifiers = ["bold"]; };
        "markup.heading.6" = { fg = "purple"; modifiers = ["bold"]; };
        "markup.list" = { fg = "light-blue"; };
        "markup.list.unnumbered" = { fg = "light-blue"; };
        "markup.list.numbered" = { fg = "light-blue"; };
        "markup.list.checked" = { fg = "green"; };
        "markup.list.unchecked" = { fg = "blue"; };
        "markup.bold" = { fg = "yellow"; modifiers = ["bold"]; };
        "markup.italic" = { fg = "purple"; modifiers = ["italic"]; };
        "markup.strikethrough" = { fg = "red"; modifiers = ["crossed_out"]; };
        "markup.link" = { fg = "light-blue"; };
        "markup.link.url" = { fg = "cyan"; modifiers = ["underlined"]; };
        "markup.link.text" = { fg = "light-blue"; };
        "markup.quote" = { fg = "grey"; };
        "markup.raw" = { fg = "brown"; };
        "markup.raw.inline" = { fg = "green"; };
        "markup.raw.block" = { fg = "brown"; };
        
        "diff" = { fg = "red"; };
        "diff.plus" = { fg = "green"; };
        "diff.minus" = { fg = "red"; };
        "diff.delta" = { fg = "cyan"; };
        "diff.delta.moved" = { fg = "cyan"; };
        "diff.delta.conflict" = { fg = "blue"; };

        "ui.background" = { bg = "white"; };
        "ui.background.separator" = { bg = "white"; };
        
        "ui.cursor" = { fg = "white"; bg = "grey"; };
        "ui.cursor.normal" = { fg = "white"; bg = "grey"; };
        "ui.cursor.insert" = { fg = "white"; bg = "grey"; };
        "ui.cursor.select" = { fg = "white"; bg = "grey"; };
        "ui.cursor.match" = { bg = "grey-300"; modifiers = ["bold"]; };
        "ui.cursor.primary" = { fg = "white"; bg = "black"; };
        "ui.cursor.primary.normal" = { fg = "white"; bg = "black"; };
        "ui.cursor.primary.insert" = { fg = "red"; bg = "black"; };
        "ui.cursor.primary.select" = { fg = "white"; bg = "black"; };

        "ui.gutter" = { fg = "grey-500"; };
        "ui.gutter.selected" = { fg = "black"; };
        
        "ui.linenr" = { fg = "grey-500"; };
        "ui.linenr.selected" = { fg = "black"; modifiers = ["bold"]; };
        
        "ui.statusline" = { fg = "black"; bg = "grey-300"; };
        "ui.statusline.inactive" = { fg = "grey"; bg = "grey-200"; };
        "ui.statusline.normal" = { fg = "grey-300"; bg = "light-blue"; };
        "ui.statusline.insert" = { fg = "grey-300"; bg = "green"; };
        "ui.statusline.select" = { fg = "grey-300"; bg = "purple"; };
        
        "ui.popup" = { fg = "black"; bg = "grey-200"; };
        "ui.popup.info" = { fg = "black"; bg = "grey-200"; };
        "ui.window" = { fg = "grey-500"; bg = "grey-100"; };
        "ui.help" = { fg = "black"; bg = "grey-200"; };

        "ui.text" = { fg = "black"; };
        "ui.text.focus" = { fg = "red"; bg = "grey-300"; modifiers = ["bold"]; };
        "ui.text.inactive" = { fg = "grey"; };
        "ui.text.info" = { fg = "black"; };
        "ui.text.directory" = { fg = "blue"; underline = { style = "line"; }; };
        
        "ui.virtual" = { fg = "grey-500"; };
        "ui.virtual.ruler" = { bg = "grey-200"; };
        "ui.virtual.wrap" = { fg = "grey-500"; };
        "ui.virtual.whitespace" = { fg = "grey-400"; };
        "ui.virtual.indent-guide" = { fg = "grey-500"; };
        "ui.virtual.inlay-hint" = { fg = "grey-500"; };
        "ui.virtual.inlay-hint.parameter" = { fg = "grey-500"; modifiers = ["italic"]; };
        "ui.virtual.inlay-hint.type" = { fg = "grey-500"; };
        "ui.virtual.jump-label" = { fg = "black"; bg = "grey-200"; modifiers = [ "bold" ]; };

        "ui.menu" = { fg = "black"; bg = "grey-300"; };
        "ui.menu.selected" = { fg = "white"; bg = "light-blue"; };
        "ui.menu.scroll" = { fg = "light-blue"; bg = "white"; };
        
        "ui.selection" = { bg = "grey-300"; modifiers = ["dim"]; };
        "ui.selection.primary" = { bg = "grey-300"; };
        
        "ui.cursorline.primary" = { fg = "white"; bg = "grey-100"; };
        "ui.cursorline.secondary" = { fg = "white"; bg = "grey-200"; };
        
        "ui.cursorcolumn.primary" = { fg = "white"; bg = "grey-100"; };
        "ui.cursorcolumn.secondary" = { fg = "white"; bg = "grey-200"; };
        
        "ui.highlight" = { bg = "grey-300"; };
        
        "ui.picker.header" = { fg = "purple"; };
        "ui.picker.header.active" = { fg = "blue"; };

        "diagnostic.info" = { underline = { color = "blue"; style = "dotted"; }; };
        "diagnostic.hint" = { underline = { color = "green"; style = "dashed"; }; };
        "diagnostic.warning" = { underline = { color = "yellow"; style = "curl"; }; };
        "diagnostic.error" = { underline = { color = "red"; style = "curl"; }; };
        "diagnostic.unnecessary" = { modifiers = ["dim"]; };
        "diagnostic.deprecated" = { modifiers = ["crossed_out"]; };
        
        "info" = { fg = "blue"; modifiers = ["bold"]; };
        "hint" = { fg = "green"; modifiers = ["bold"]; };
        "warning" = { fg = "yellow"; modifiers = ["bold"]; };
        "error" = { fg = "red"; modifiers = ["bold"]; };
        
        "tabstop" = { modifiers = ["italic"]; bg = "grey-300"; };

        palette = {
          white = "#FFFFFF";
          yellow = "#FF6F00";
          gold = "#D35400";
          brown = "#795548";
          blue = "#0061FF";
          light-blue = "#0096FF";
          red = "#E3242B";
          pink = "#C2185B";
          purple = "#B500A9";
          deep-purple = "#651FFF";
          green = "#3E9B0A";
          cyan = "#0086C1";
          black = "#000000";
          grey = "#595959";
          grey-500 = "#9E9E9E";
          grey-400 = "#BDBDBD";
          grey-300 = "#E0E0E0";
          grey-200 = "#EEEEEE";
          grey-100 = "#F2F2F2";        
        };
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

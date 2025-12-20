{ lib, ... }:
{
  programs.alacritty = {
    enable = true;
    theme = "tokyo_night";
    settings = {
      window.decorations = "None";
      font = {
        size = 12.25;
        bold = {
          family = lib.mkForce "JetBrainsMono Nerd Font Mono";
          style = "Bold";
        };
        bold_italic = {
          family = lib.mkForce "JetBrainsMono Nerd Font Mono";
          style = "Bold Italic";
        };
        italic = {
          family = lib.mkForce "JetBrainsMono Nerd Font Mono";
          style = "Italic";
        };
        normal = {
          family = lib.mkForce "JetBrainsMono Nerd Font Mono";
          style = "Regular";
        };

        builtin_box_drawing = true;
        glyph_offset = {
          x = 0;
          y = 0;
        };
        # offset = {
        #   x = 0;
        #   y = 9;
        # };
      };

      scrolling = {
        history = 100000;
        multiplier = 4;
      };

      selection = {
        save_to_clipboard = true;
        semantic_escape_chars = '',│`|:"' ()[]{}<>	'';
      };
    };
  };
}

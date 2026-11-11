{
  lib,
  pkgs,
  ...
}:
let
  monoFont = "JetBrainsMono Nerd Font";
  formatOnSave = {
    formatter = "language_server";
    format_on_save = "on";
  };
in
{
  home.shellAliases.zed = "zeditor";

  programs.zed-editor = {
    enable = true;
    package = if pkgs.stdenv.isLinux then pkgs.zed-editor.fhs else pkgs.zed-editor;
    # Keep settings editable while trying Zed; Home Manager reapplies declared values.
    mutableUserSettings = true;
    mutableUserKeymaps = true;

    # Rust, C/C++, Vim, Git, SSH, dev containers and CodeLLDB are built in.
    extensions = [
      "nix"
      "dockerfile"
      "vscode-2026-theme"
    ];

    # https://zed.dev/docs/reference/all-settings
    userSettings = {
      base_keymap = "VSCode";
      vim_mode = true;
      buffer_font_family = monoFont;
      buffer_font_size = 14;
      # Icons scale with the UI font size, independently of the editor text.
      ui_font_size = 18;
      project_panel.dock = "left";
      agent = {
        dock = "right";
        threads_sidebar.position = "right";
      };
      # Show multiple definitions/references in a picker instead of a multibuffer.
      # A single definition still opens directly; Ctrl-W D opens it in a split in Vim normal mode.
      lsp_results_location = "picker";
      terminal.font_family = monoFont;
      terminal.font_size = 14;
      theme = "VS Code Dark 2026";
      colorize_brackets = true;
      indent_guides.coloring = "indent_aware";
      load_direnv = "direct";
      git.inline_blame.enabled = true;
      inlay_hints.enabled = true;

      # https://zed.dev/docs/ai/external-agents#custom-agents
      agent_servers.Codex = {
        type = "custom";
        command = lib.getExe pkgs.codex-acp;
        args = [ ];
      };

      # VS Code only formats Rust and C/C++ on save in this configuration.
      format_on_save = "off";
      languages = {
        Rust = formatOnSave;
        C = formatOnSave;
        "C++" = formatOnSave;
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
          formatter.external = {
            command = "nixfmt";
            arguments = [ ];
          };
        };
      };
    };

    userKeymaps = [
      {
        context = "Editor";
        # Match vscodevim's vim.handleKeys.<C-p> = false, including insert mode.
        bindings.ctrl-p = "file_finder::Toggle";
      }
      {
        context = "Workspace";
        bindings."ctrl-\\" = "terminal_panel::Toggle";
      }
      {
        # Match diy.nvim's Space leader without intercepting typing or menus.
        context = "Editor && mode == full && vim_mode == normal && !menu";
        bindings = {
          "\\" = "project_panel::Toggle";
          "space s f" = "file_finder::Toggle";
          "space s g" = "pane::DeploySearch";
          "space s k" = "zed::OpenKeymap";
          "space s s" = "command_palette::Toggle";
          "space space" = "tab_switcher::Toggle";
          # Zed's buffer search is literal/regex, rather than Telescope fuzzy search.
          "space /" = "buffer_search::Deploy";
          "space s d" = "diagnostics::Deploy";
          "space q" = "diagnostics::Deploy";
          "space x x" = "diagnostics::Deploy";
          "space d s" = "outline::Toggle";
          "space w s" = "project_symbols::Toggle";
          "space c s" = "outline_panel::ToggleFocus";
          "space t o" = "outline_panel::ToggleFocus";
          "space c r" = "editor::Rename";
          "space t h" = "editor::ToggleInlayHints";
          "g r" = "editor::FindAllReferences";

          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
          "space b p" = "pane::TogglePinTab";
          "space b shift-p" = [
            "pane::CloseAllItems"
            { close_pinned = false; }
          ];
          "space b r" = [
            "pane::CloseItemsToTheRight"
            { close_pinned = false; }
          ];
          "space b l" = [
            "pane::CloseItemsToTheLeft"
            { close_pinned = false; }
          ];
          # Keep Zed's save prompt instead of Neovim's destructive bdelete!.
          "space b d" = [
            "pane::CloseActiveItem"
            { close_pinned = true; }
          ];

          "ctrl-up" = "vim::ResizePaneUp";
          "ctrl-down" = "vim::ResizePaneDown";
          "ctrl-left" = "vim::ResizePaneLeft";
          "ctrl-right" = "vim::ResizePaneRight";
          "] h" = "editor::GoToHunk";
          "[ h" = "editor::GoToPreviousHunk";
          "space g p" = "editor::ToggleSelectedDiffHunks";
          "space g b" = "editor::BlameHover";
          "space g shift-b" = "git::Blame";
          "space t b" = "editor::ToggleGitBlameInline";

          # Basic mini.surround habits; Zed uses its own surround implementation.
          "s a" = [
            "vim::PushAddSurrounds"
            { }
          ];
          "s d" = "vim::PushDeleteSurrounds";
          "s r" = [
            "vim::PushChangeSurrounds"
            { }
          ];
        };
      }
      {
        context = "Editor && mode == full && (vim_mode == normal || vim_mode == visual) && !menu";
        bindings = {
          "space c a" = "editor::ToggleCodeActions";
          "space c f" = "editor::Format";
        };
      }
      {
        context = "EmptyPane || (ProjectPanel && not_editing)";
        bindings."\\" = "project_panel::Toggle";
      }
    ];
  };

  # Keep these on PATH so GUI launches work and direnv can supply project versions.
  # This also avoids downloading non-Nix language-server binaries on NixOS.
  home.packages = with pkgs; [
    nixd
    nixfmt
    rust-analyzer
    rustfmt
    clang-tools
  ];
}

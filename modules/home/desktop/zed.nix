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
      "catppuccin"
      "catppuccin-icons"
    ];

    # https://zed.dev/docs/reference/all-settings
    userSettings = {
      base_keymap = "VSCode";
      vim_mode = true;
      which_key = {
        enabled = true;
        delay_ms = 300;
      };
      buffer_font_family = monoFont;
      buffer_font_size = 14;
      # Use native macOS fonts, or the Source fonts installed by the Linux font module.
      ui_font_family = if pkgs.stdenv.isDarwin then ".SystemUIFont" else "Source Sans 3";
      ui_font_fallbacks =
        if pkgs.stdenv.isDarwin then
          [
            "PingFang SC"
            "Hiragino Sans GB"
          ]
        else
          [ "Source Han Sans SC" ];
      # Zed has no density setting: labels, icons and bar heights all scale with this value
      # (labels render at 14px * size / 16). 15 gives ~13px labels like VS Code's workbench,
      # keeping the UI text slightly smaller than the 14px editor text.
      ui_font_size = 15;
      # Panel inputs default to 12px, which looks undersized next to the editor.
      agent_buffer_font_size = 14;
      git_commit_buffer_font_size = 14;
      tabs = {
        file_icons = true;
        git_status = true;
      };
      project_panel.dock = "left";
      # Rows already use the roomiest `comfortable` spacing, so extra whitespace comes from width.
      project_panel.default_width = 300;
      agent = {
        dock = "right";
        threads_sidebar.position = "right";
      };
      # Show multiple definitions/references in a picker instead of a multibuffer.
      # A single definition still opens directly; Ctrl-W D opens it in a split in Vim normal mode.
      lsp_results_location = "picker";
      terminal.font_family = monoFont;
      terminal.font_size = 14;
      theme = "Catppuccin Mocha";
      icon_theme = "Catppuccin Mocha";
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
        context = "Editor && !menu";
        # Keep file search outside menus; completion menus use Neovim's Ctrl-P.
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
          # Unbind Vim's single-Space motion so the leader menu can wait for input.
          space = null;
          "\\" = "project_panel::Toggle";
          escape = [
            "action::Sequence"
            [
              "vim::SwitchToNormalMode"
              "buffer_search::Dismiss"
            ]
          ];
          "space s f" = "file_finder::Toggle";
          # Project search multibuffer that stays open, for stepping through matches one by one.
          "space s g" = "pane::DeploySearch";
          "space s w" = [
            "pane::DeploySearch"
            {
              whole_word = true;
              regex = false;
            }
          ];
          # Text finder picker with a preview pane. Enter or a double click opens the match and
          # closes the picker; the picker's "Open as Tab" (Alt-Cmd-F) keeps the results instead.
          "space s shift-g" = "text_finder::Toggle";
          # The picker only seeds from a selection, so select the word under the cursor first.
          "space s shift-w" = [
            "workspace::SendKeystrokes"
            "v i w space s shift-w"
          ];
          # The file finder lists recent files before a query is entered.
          "space s ." = "file_finder::Toggle";
          "space s k" = "zed::OpenKeymap";
          "space s s" = "command_palette::Toggle";
          "space s h" = "zed::OpenDocs";
          "space s r" = "workspace::ReopenLastPicker";
          # Zed's own settings replace searching the Neovim config directory.
          "space s n" = "zed::OpenSettingsFile";
          "space space" = "tab_switcher::Toggle";
          # Zed's buffer search is literal/regex, rather than Telescope fuzzy search.
          "space /" = "buffer_search::Deploy";
          "space s d" = "diagnostics::Deploy";
          "space q" = "diagnostics::Deploy";
          "space x x" = "diagnostics::Deploy";
          "space x shift-x" = "diagnostics::DeployCurrentFile";
          # Native references picker replaces Trouble's combined LSP panel.
          "space c l" = "editor::FindAllReferences";
          "space d s" = "outline::Toggle";
          "space w s" = "project_symbols::Toggle";
          "space c s" = "outline_panel::ToggleFocus";
          "space t o" = "outline_panel::ToggleFocus";
          "space c r" = "editor::Rename";
          "space c h" = "editor::SwitchSourceHeader";
          "space t h" = "editor::ToggleInlayHints";
          "g r" = "editor::FindAllReferences";
          "space p shift-s" = "projects::OpenRecent";

          # Use the configured Zed agent; adding context does not submit a prompt.
          "ctrl-." = "agent::ToggleFocus";
          "g o o" = "agent::AddSelectionToThread";
          "+" = "vim::Increment";
          "-" = "vim::Decrement";

          "shift-h" = "pane::ActivatePreviousItem";
          "shift-l" = "pane::ActivateNextItem";
          "[ b" = "pane::SwapItemLeft";
          "] b" = "pane::SwapItemRight";
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
          "space b c" = [
            "pane::CloseActiveItem"
            { close_pinned = true; }
          ];
          "space b o" = [
            "pane::CloseOtherItems"
            { close_pinned = false; }
          ];

          "ctrl-up" = "vim::ResizePaneUp";
          "ctrl-down" = "vim::ResizePaneDown";
          "ctrl-left" = "vim::ResizePaneLeft";
          "ctrl-right" = "vim::ResizePaneRight";
          "] h" = "editor::GoToHunk";
          "[ h" = "editor::GoToPreviousHunk";
          "space g p" = "editor::ToggleSelectedDiffHunks";
          "space g d" = "git::OpenFileDiff";
          # Unstage the current hunk, not Gitsigns' historical undo-stage operation.
          "space g u" = "git::UnstageAndNext";
          "space g b" = "editor::BlameHover";
          "space g shift-b" = "git::Blame";
          "space t b" = "editor::ToggleGitBlameInline";
          # Deleted lines are shown as part of expanded inline diffs.
          "space t shift-d" = "editor::ToggleAllDiffHunks";

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
          # Zed stages whole intersecting hunks; normal mode also advances to the next.
          "space g h s" = "git::StageAndNext";
          "space g h r" = "git::Restore";
          "ctrl-a" = "agent::AddSelectionToThread";
          # Structural selection is the closest native alternative to Treewalker.
          "ctrl-j" = "vim::SelectNextSyntaxNode";
          "ctrl-k" = "vim::SelectPreviousSyntaxNode";
          "ctrl-h" = "vim::SelectLargerSyntaxNode";
          "ctrl-l" = "vim::SelectSmallerSyntaxNode";
        };
      }
      {
        # Never let whole-file operations act on a multibuffer of unrelated files.
        context = "Editor && mode == full && vim_mode == normal && !menu && !multibuffer";
        bindings = {
          "space g shift-s" = [
            "action::Sequence"
            [
              "editor::SelectAll"
              "git::StageAndNext"
              "vim::NormalBefore"
            ]
          ];
          "space g shift-r" = "git::RestoreFile";
        };
      }
      {
        context = "Editor && mode == full && vim_mode == visual && !menu";
        bindings = {
          # Same as normal mode: let the leader menu wait for input instead of moving right.
          space = null;
          "space s g" = "pane::DeploySearch";
          "space s shift-g" = "text_finder::Toggle";
          "space s shift-w" = "text_finder::Toggle";
          "g o" = "agent::AddSelectionToThread";
          "s a" = [
            "vim::PushAddSurrounds"
            { }
          ];
        };
      }
      {
        context = "Editor && mode == full && vim_mode == insert";
        bindings."ctrl-space" = "editor::ShowCompletions";
      }
      {
        context = "Editor && mode == full && vim_mode == insert && showing_completions";
        bindings = {
          "ctrl-n" = "editor::ContextMenuNext";
          "ctrl-p" = "editor::ContextMenuPrevious";
          tab = "editor::ContextMenuNext";
          "shift-tab" = "editor::ContextMenuPrevious";
          "ctrl-y" = "editor::ConfirmCompletion";
          enter = "editor::ConfirmCompletion";
          "ctrl-b" = "vim::ScrollUp";
          "ctrl-f" = "vim::ScrollDown";
        };
      }
      {
        context = "Editor && in_snippet && has_next_tabstop";
        bindings."ctrl-l" = "editor::NextSnippetTabstop";
      }
      {
        context = "Editor && in_snippet && has_previous_tabstop";
        bindings."ctrl-h" = "editor::PreviousSnippetTabstop";
      }
      {
        context = "Terminal";
        bindings = {
          # Zed terminals have no Vim terminal-normal mode; return to the editor.
          "escape escape" = "workspace::FocusCenterPane";
          "ctrl-." = "agent::ToggleFocus";
        };
      }
      {
        context = "EmptyPane || (ProjectPanel && not_editing)";
        bindings."\\" = "project_panel::Toggle";
      }
      {
        context = "ProjectPanel && not_editing";
        bindings = {
          a = "project_panel::NewFile";
          "shift-a" = "project_panel::NewDirectory";
          d = [
            "project_panel::Delete"
            { skip_prompt = false; }
          ];
          r = "project_panel::Rename";
          y = "project_panel::Copy";
          x = "project_panel::Cut";
          # diy.nvim overrides Neo-tree's paste key with focus_preview.
          p = "project_panel::Open";
          "shift-p" = "project_panel::Open";
          s = "project_panel::OpenSplitVertical";
          "shift-s" = "project_panel::OpenSplitHorizontal";
          "shift-c" = "project_panel::CollapseSelectedEntry";
          z = "project_panel::CollapseAllEntries";
          q = "project_panel::Toggle";
          "[ g" = "project_panel::SelectPrevGitEntry";
          "] g" = "project_panel::SelectNextGitEntry";
          "/" = "file_finder::Toggle";
          "?" = "zed::OpenKeymap";
        };
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

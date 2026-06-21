{
  lib,
  pkgs,
  ...
}:
let
  monoFont = "JetBrainsMono Nerd Font";
in
{
  programs.vscode = {
    enable = true;
    package = if pkgs.stdenv.isLinux then pkgs.vscode.fhs else pkgs.vscode;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        mkhl.direnv

        llvm-vs-code-extensions.vscode-clangd
        vadimcn.vscode-lldb
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-containers
        ms-azuretools.vscode-docker
        catppuccin.catppuccin-vsc
        rust-lang.rust-analyzer
        vscodevim.vim
        eamodio.gitlens
      ];

      userSettings = {
        "window.zoomLevel" = 0.75;
        "editor.fontFamily" = lib.mkForce monoFont;
        "editor.fontSize" = lib.mkForce 14;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        "[rust]" = {
          "editor.defaultFormatter" = "rust-lang.rust-analyzer";
          "editor.formatOnSave" = true;
        };
        "[c]" = {
          "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
          "editor.formatOnSave" = true;
        };
        "[cpp]" = {
          "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
          "editor.formatOnSave" = true;
        };
        "editor.inlayHints.fontFamily" = lib.mkForce monoFont;
        "editor.inlineSuggest.fontFamily" = lib.mkForce monoFont;
        "debug.console.fontFamily" = lib.mkForce monoFont;
        "scm.inputFontFamily" = lib.mkForce monoFont;
        "terminal.integrated.fontFamily" = lib.mkForce monoFont;
        "workbench.colorTheme" = lib.mkForce "Catppuccin Mocha";
        "vim.handleKeys" = {
          "<C-p>" = false;
        };
      };
    };
  };

  home.packages = with pkgs; [
    rustfmt
    clang-tools
  ];
}

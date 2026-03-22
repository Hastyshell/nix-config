{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  xdg.configFile."nvim".source = inputs.nvim-config.outPath;
  programs.neovim = {
    enable = true;

    # These environment variables are needed to build and run binaries
    # with external package managers like mason.nvim.
    #
    # LD_LIBRARY_PATH is also needed to run the non-FHS binaries downloaded by mason.nvim.
    # If we really need mason.nvim, we should enable nix-ld to set it, or set it here manually.
    extraWrapperArgs = with pkgs; [
      # LIBRARY_PATH is used by gcc before compilation to search directories
      # containing static and shared libraries that need to be linked to your program.
      "--suffix"
      "LIBRARY_PATH"
      ":"
      "${lib.makeLibraryPath [
        stdenv.cc.cc
        zlib
      ]}"

      # PKG_CONFIG_PATH is used by pkg-config before compilation to search directories
      # containing .pc files that describe the libraries that need to be linked to your program.
      "--suffix"
      "PKG_CONFIG_PATH"
      ":"
      "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
        stdenv.cc.cc
        zlib
      ]}"
    ];

    extraPackages = with pkgs; [
      luajit
      gnumake
      gcc
      fzf
      ripgrep

      nixd
      nixfmt-rfc-style
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files

      lua-language-server
      stylua

      # clang-tools
      #
      # pyright
      # ruff
      #
      # rust-analyzer
      # rustfmt
      # clippy
      #
      # gomodifytags
      # iferr # generate error handling code for go
      # impl # generate function implementation for go
      # gotools # contains tools like: godoc, goimports, etc.
      # gopls # go language server
      # delve # go debugger
      #
      # jdt-language-server

      taplo # TOML language server / formatter / validator
      nodePackages.yaml-language-server
      actionlint # GitHub Actions linter
      hadolint # Dockerfile linter
      marksman # language server for markdown

      buf # -- protocol buffer linting and formatting
      sqlfluff # sql
      nodePackages.bash-language-server
      shellcheck
      shfmt
      cmake-language-server
    ];

  };
}

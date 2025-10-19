{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      # archives
      zip
      xz
      zstd
      lz4

      fd
      # Text Processing
      jq
      yq-go
      (ripgrep.override { withPCRE2 = true; })
      nushell

      fastfetch

      rclone
      rsync

      hunspell # Spell checker
      ffmpeg-full

      mycli
      pgcli
      sqlite

      just
      tree

      pandoc
    ]
    ++ [
      #-- python
      (python313.withPackages (
        ps: with ps; [
          pyright
          ruff
        ]
      ))
    ];

  # use program to make stylix work
  programs.btop.enable = true;
}

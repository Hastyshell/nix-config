{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "satty-shot";

  runtimeInputs = with pkgs; [
    grim
    slurp
    satty
    wl-clipboard
    coreutils
  ];

  text = ''
    set -euo pipefail

    usage() {
      echo "Usage: satty-shot [OUTPUT_DIR]"
      echo
      echo "If OUTPUT_DIR is not provided, defaults to:"
      echo "  \$XDG_PICTURES_DIR/screenshots"
      exit 1
    }

    if [ "''${1:-}" = "-h" ] || [ "''${1:-}" = "--help" ]; then
      usage
    fi

    if [ "$#" -gt 1 ]; then
      echo "error: too many arguments" >&2
      usage
    fi

    DEFAULT_DIR="''${XDG_PICTURES_DIR:-$HOME/Pictures}/screenshots"
    OUT_DIR="''${1:-$DEFAULT_DIR}"

    mkdir -p "$OUT_DIR"

    grim -t png -g "$(slurp)" - |
      satty -f - \
        --initial-tool=arrow \
        --copy-command=wl-copy \
        --actions-on-escape=exit \
        --brush-smooth-history-size=5 \
        --output-filename \
          "$OUT_DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
  '';

  meta = {
    description = "Wayland screenshot helper using grim + slurp + satty";
  };
}

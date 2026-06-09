{ self, ... }:
{
  hostname = "hasty-earningd";
  username = "hastyshell";
  homeDirectory = "/data/hastyshell";
  fullName = "Siyang Tang";
  email = "tangsiyang@xiaohongshu.com";
  system = "x86_64-linux";
  homeModules = [
    self.homeModules.default
    (
      { pkgs, ... }:
      {
        custom.home.codex.proxy.enable = true;

        home.sessionVariables = {
          PATH = "$HOME/.nix-profile/bin:$PATH";
          GIT_SSH_COMMAND = "ssh -F none";
          JAVA_8_HOME = "${pkgs.jdk8}";
          JAVA_17_HOME = "${pkgs.jdk17}/lib/openjdk";
          JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
        };
        home.sessionPath = [
          "${pkgs.jdk17}/lib/openjdk/bin"
        ];
      }
    )
    (
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        npmGlobal = "${config.home.homeDirectory}/.local/share/npm-global";
      in
      {
        home.packages = with pkgs; [
          maven
          nodejs
        ];

        home.sessionVariables = {
          NPM_CONFIG_PREFIX = npmGlobal;
          npm_config_prefix = npmGlobal;
        };

        home.sessionPath = [
          "${npmGlobal}/bin"
        ];

        home.activation.createNpmGlobalPrefix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p ${lib.escapeShellArg npmGlobal}/bin
          mkdir -p ${lib.escapeShellArg npmGlobal}/lib/node_modules
        '';
      }
    )
    (
      { lib, ... }:
      {
        programs.zsh.initContent = lib.mkBefore ''
          ZSH_DISABLE_COMPFIX="true"
        '';
      }
    )
    (
      { lib, ... }:
      {
        programs.zsh.initContent = lib.mkAfter ''
          export CLASHCTL_HOME=/data/hastyshell/clashctl
          . $CLASHCTL_HOME/scripts/cmd/clashctl.sh
        '';
      }
    )
    (
      { lib, ... }:
      {
        programs.zsh.initContent = lib.mkAfter ''
          _use-java() {
            local java_home="$1"
            local clean_path

            clean_path=$(printf '%s' "$PATH" | tr ':' '\n' | grep -vE '/openjdk-(8|17)' | paste -sd ':' -)
            export JAVA_HOME="$java_home"
            export PATH="$JAVA_HOME/bin:''${clean_path}"
            java -version
          }

          use-java8() {
            _use-java "$JAVA_8_HOME"
          }

          use-java17() {
            _use-java "$JAVA_17_HOME"
          }
        '';
      }
    )
  ];
}

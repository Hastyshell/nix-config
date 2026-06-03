{ self, ... }:
{
  hostname = "hasty-earningd";
  username = "tangsiyang";
  homeDirectory = "/mnt/disk1/tangsiyang";
  fullName = "Siyang Tang";
  email = "tangsiyang@selectdb.com";
  system = "x86_64-linux";
  homeModules = [
    self.homeModules.default
    (
      { pkgs, ... }:
      {
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
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          maven
          nodejs
        ];
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

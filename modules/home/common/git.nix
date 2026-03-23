{
  programs.git = {
    enable = true;
    ignores = [ "*.swp" ];
    lfs = {
      enable = true;
    };
    settings = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
        askpass = "";
      };
      # commit.gpgsign = true;
      pull.rebase = true;
      rebase.autoStash = true;
      credential.helper = "store";
    };
  };
}

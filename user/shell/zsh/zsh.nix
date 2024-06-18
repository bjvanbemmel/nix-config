{ config, pkgs, ... }:

{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      v = "nvim";
    };

    autosuggestion.enable =  true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "sindresorhus";
          repo = "pure";
          rev = "v1.23.0";
          hash = "sha256-Hdb5wGVkNrmmVWZaKf3xUnNYsTX/8Bb7AhgLNJxNAUc=";
        };
      }
      {
        name = "vi-mode";
        src = pkgs.fetchFromGitHub {
          owner = "jeffreytse";
          repo = "zsh-vi-mode";
          rev = "287efa19ec492b2f24bb93d1f4eaac3049743a63";
          hash = "sha256-HMfC4s7KW4bO7H6RYzLnSARoFr1Ez89Z2VGONKMpGbw=";
        };
      }
    ];
  };
}
	

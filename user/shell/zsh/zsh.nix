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
    ];
  };
}
	

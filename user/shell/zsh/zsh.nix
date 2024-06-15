{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    shellAliases = {
      v = "nvim";
    };
  };
}
	

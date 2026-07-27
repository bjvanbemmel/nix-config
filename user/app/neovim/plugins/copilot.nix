{ ... }:

{
  programs.nixvim.plugins.copilot-lua = {
    enable = true;
    settings = {
      suggestion.enabled = false; # handled via copilot-cmp instead
      panel.enabled = false;
    };
  };

  programs.nixvim.plugins.copilot-cmp.enable = true;
}

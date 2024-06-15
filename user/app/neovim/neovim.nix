{ config, pkgs, ...}:

{
  imports = [
    ./plugins/lsp.nix
    ./plugins/cmp.nix
    ./plugins/comment.nix
    ./plugins/oil.nix
    ./plugins/luasnip.nix
    ./plugins/telescope.nix
    ./plugins/treesitter.nix
    ./keybinds.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    colorschemes.gruvbox.enable = true;

    opts = {
      updatetime = 100; # This will make the autocompletion faster

      # Line numbers
      relativenumber = true;
      number = true;

      # Tab
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      autoindent = true;

      # Misc
      swapfile = false; # This might be the end of me one day, but I prefer losing progress over those annoying pop-ups
      undofile = true; # Persistent undo history
      wrap = true; # Overflowing text will wrap to a new pseudo-line
      mouse = ""; # Disable the annoying mouse control
    };
  };
}

{ configs, pkgs, ...}:

{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      {
        key = "gti";
        mode = [ "n" "v" ];
        action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
      }
      {
        key = "gtd";
        mode = [ "n" "v" ];
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      }
      {
        key = "gtr";
        mode = [ "n" "v" ];
        action = "<cmd>lua vim.lsp.buf.references()<CR>";
      }
      {
        key = "<leader>r";
        mode = [ "n" "v" ];
        action = "<cmd>lua vim.lsp.buf.rename()<CR>"; # Todo: make this a function that also writes every affected file
      }
    ];
  };
}

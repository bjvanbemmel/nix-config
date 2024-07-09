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
        key = "<leader>r";
        mode = [ "n" "v" ];
        action = "<cmd>lua vim.lsp.buf.rename()<CR>"; # Todo: make this a function that also writes every affected file
      }
      {
        key = "<leader>a";
        mode = [ "n" "v" ];
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; # Todo: make this a function that also writes every affected file
      }
      {
        key = "<leader>d";
        mode = [ "n" ];
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      }
      {
        key = "<leader>s";
        mode = [ "n" ];
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      }
    ];
  };
}

{ config, pkgs, ... }:

{
  programs.nixvim.plugins.telescope = {
    enable = true;

    keymaps = {
      "<leader>tf" = {
        action = "find_files";
      };
      "<leader>td" = {
        action = "diagnostics";
      };
      "<leader>ti" = {
        action = "lsp_implementations";
      };
      "<leader>tg" = {
        action = "live_grep";
      };
      "<leader>tbf" = {
        action = "current_buffer_fuzzy_find";
      };
      "gtr" = {
        action = "lsp_incoming_calls";
      };
    };
  };
}

{ pkgs, ... }:

{
  programs.nixvim.extraPlugins = [ pkgs.vimPlugins.cmp-ai ];

  programs.nixvim.extraConfigLua = ''
    vim.env.HF_API_KEY = "unused"
    require('cmp_ai.config'):setup({
      max_lines = 1000,
      provider = 'Ollama',
      provider_options = {
        model = 'qwen2.5-coder:1.5b',
        base_url = 'http://10.100.0.1:11434',
      },
      run_on_every_keystroke = true,
    })
  '';
}

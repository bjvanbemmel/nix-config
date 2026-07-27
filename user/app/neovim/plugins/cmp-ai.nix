{ pkgs, ... }:

{
  programs.nixvim.extraPlugins = [ pkgs.vimPlugins.cmp-ai ];

  programs.nixvim.extraConfigLua = ''
    require('cmp_ai.config'):setup({
      max_lines = 1000,
      provider = 'Ollama',
      provider_options = {
        model = 'mistral:7b',
        base_url = 'http://10.100.0.1:11434',
      },
      run_on_every_keystroke = false,
    })
  '';
}

{ ... }:

{
  programs.nixvim.extraConfigLua = ''
    do
      local source = {}

      source.new = function()
        return setmetatable({}, { __index = source })
      end

      source.is_available = function()
        return true
      end

      source.get_keyword_pattern = function()
        return [[\k\+]]
      end

      source.complete = function(_, request, callback)
        local bufnr   = vim.api.nvim_get_current_buf()
        local cursor  = request.context.cursor
        local lines   = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        local prefix_lines = vim.list_slice(lines, 1, cursor.row)
        prefix_lines[#prefix_lines] = string.sub(prefix_lines[#prefix_lines] or "", 1, cursor.col)
        local prefix = table.concat(prefix_lines, "\n")

        local suffix_lines = vim.list_slice(lines, cursor.row + 1, #lines)
        table.insert(suffix_lines, 1, string.sub(lines[cursor.row + 1] or "", cursor.col + 1))
        local suffix = table.concat(suffix_lines, "\n")

        local prompt = "<|fim_prefix|>" .. prefix .. "<|fim_suffix|>" .. suffix .. "<|fim_middle|>"

        local body = vim.json.encode({
          model   = "qwen2.5-coder:1.5b",
          prompt  = prompt,
          stream  = false,
          options = { num_predict = 64, temperature = 0.1, stop = { "\n\n" } },
        })

        vim.system(
          { "curl", "-s", "--max-time", "5", "-X", "POST",
            "http://10.100.0.1:11434/api/generate",
            "-H", "Content-Type: application/json", "-d", body },
          { text = true },
          function(result)
            vim.schedule(function()
              if result.code ~= 0 then
                callback({ items = {}, isIncomplete = false })
                return
              end
              local ok, data = pcall(vim.json.decode, result.stdout)
              local text = ok and data and vim.trim(data.response or "") or ""
              if text == "" then
                callback({ items = {}, isIncomplete = false })
                return
              end
              callback({
                items = {{
                  label      = text,
                  insertText = text,
                  kind       = require("cmp").lsp.CompletionItemKind.Text,
                }},
                isIncomplete = false,
              })
            end)
          end
        )
      end

      require("cmp").register_source("ollama", source)
    end
  '';
}

{ config, pkgs, ... }:

{
  programs.nixvim.plugins.codecompanion = {
    enable = true;

    settings = {
      # Custom adapters MUST live under `adapters.http` in CodeCompanion v19 —
      # every lookup (adapter resolution, `adapter=` syntax) reads
      # `config.adapters.http[<name>]`. Registering them at the top level is a
      # silent no-op and the strategy falls back to a default (non-Ollama)
      # adapter.
      adapters.http = {
        # Chat adapter — free-form responses, no output constraints.
        ollamaChat.__raw = ''
          function()
            return require("codecompanion.adapters").extend("ollama", {
              env = {
                url = "http://10.100.0.1:11434",
              },
              schema = {
                model = { default = "qwen2.5-coder:7b" },
                num_ctx = { default = 16384 },
              },
            })
          end
        '';

        # Inline adapter — used by the floating prompt below. Ollama's
        # structured-output mode (`format` = a JSON schema) constrains the
        # model so it can ONLY emit JSON matching the exact shape
        # CodeCompanion's inline assistant parses. This is what guarantees the
        # response is always valid, parseable JSON.
        ollamaInline.__raw = ''
          function()
            return require("codecompanion.adapters").extend("ollama", {
              env = {
                url = "http://10.100.0.1:11434",
              },
              handlers = {
                -- `form_parameters` output is merged verbatim into the top
                -- level of the Ollama /api/chat request body, so setting
                -- `format` here sends Ollama a JSON schema to constrain
                -- generation against.
                form_parameters = function(self, params, messages)
                  local openai = require("codecompanion.adapters.http.openai")
                  local result = openai.handlers.form_parameters(self, params, messages)
                  result.format = {
                    type = "object",
                    properties = {
                      code = { type = "string" },
                      language = { type = "string" },
                      placement = {
                        type = "string",
                        -- "chat" is intentionally omitted: we always want code
                        -- written into the buffer, never a chat reply.
                        enum = { "replace", "add", "before", "new" },
                      },
                    },
                    required = { "code", "language", "placement" },
                  }
                  return result
                end,

                -- Hand CodeCompanion the raw JSON string. Structured output
                -- means this is already clean; we defensively strip stray code
                -- fences so parsing can never fail.
                inline_output = function(self, data, context)
                  if not data or data == "" then
                    return nil
                  end
                  local ok, body = pcall(vim.json.decode, data.body, { luanil = { object = true } })
                  if not ok or not (body and body.message) then
                    return { status = "error", output = "Ollama returned an undecodable response" }
                  end
                  local content = vim.trim(body.message.content or "")
                  content = content:gsub("^```json%s*", ""):gsub("^```%s*", ""):gsub("%s*```$", "")
                  return { status = "success", output = vim.trim(content) }
                end,
              },
              schema = {
                model = { default = "qwen2.5-coder:7b" },
                num_ctx = { default = 16384 },
              },
            })
          end
        '';
      };

      # v19 renamed `strategies` -> `interactions` (the old key still works via
      # a compat shim, but only if you don't ALSO pass `interactions`). We use
      # the modern key directly.
      interactions = {
        chat.adapter = "ollamaChat";
        inline.adapter = "ollamaInline";
        agent.adapter = "ollamaChat";

        # Friendlier accept/reject keys on the inline diff (defaults are
        # g1/g2/g3). The diff banner picks these up automatically.
        shared.keymaps = {
          always_accept.modes.n = "gA";
          accept_change.modes.n = "ga";
          reject_change.modes.n = "gr";
        };
      };

      display = {
        action_palette.provider = "telescope";
        diff.enabled = true;
        inline.layout = "vertical";
        chat.window = {
          layout = "float";
          relative = "editor";
          border = "rounded";
          height = 0.8;
          width = 0.45;
        };
      };
    };
  };

  programs.nixvim.extraConfigLua = ''
    -- ══ Activity indicator ═══════════════════════════════════════════════
    -- A cmdline spinner while any CodeCompanion request is in flight, so it's
    -- obvious the (local, and therefore slower) model is working.
    local cc_spinner = {
      frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
      idx = 1,
      timer = nil,
    }

    local function cc_spinner_stop()
      if cc_spinner.timer then
        pcall(vim.fn.timer_stop, cc_spinner.timer)
        cc_spinner.timer = nil
      end
      vim.api.nvim_echo({ { "" } }, false, {})
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionRequestStarted",
      callback = function()
        cc_spinner_stop()
        cc_spinner.idx = 1
        cc_spinner.timer = vim.fn.timer_start(90, function()
          cc_spinner.idx = (cc_spinner.idx % #cc_spinner.frames) + 1
          vim.api.nvim_echo(
            { { "  " .. cc_spinner.frames[cc_spinner.idx] .. "  CodeCompanion is working…", "Comment" } },
            false, {}
          )
        end, { ["repeat"] = -1 })
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionRequestFinished",
      callback = cc_spinner_stop,
    })

    -- ══ Floating prompt (Telescope-like) ═════════════════════════════════
    -- Opens a centered floating input. On <CR> it fires the inline assistant,
    -- which writes the model's code into the buffer and shows a diff to
    -- accept (ga) or reject (gr). Works from normal mode (insert at cursor)
    -- and visual mode (rewrite the selection).
    local function cc_inline_prompt()
      local src_win = vim.api.nvim_get_current_win()
      local mode = vim.fn.mode()
      local was_visual = (mode == "v" or mode == "V")

      -- Leave visual mode first so the '< and '> marks capture the selection;
      -- the "nx" flags make this happen synchronously.
      if was_visual then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
      end

      local buf = vim.api.nvim_create_buf(false, true)
      local width = math.floor(vim.o.columns * 0.6)
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = 1,
        row = math.floor(vim.o.lines * 0.3),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = was_visual and " CodeCompanion — edit selection " or " CodeCompanion ",
        title_pos = "center",
      })

      local done = false
      local function close()
        if done then
          return
        end
        done = true
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end

      -- Prompt buffers hand us the typed text (minus the prefix) on <CR>.
      vim.bo[buf].buftype = "prompt"
      vim.fn.prompt_setprompt(buf, "❯ ")
      vim.fn.prompt_setcallback(buf, function(text)
        close()
        if vim.api.nvim_win_is_valid(src_win) then
          vim.api.nvim_set_current_win(src_win)
        end
        text = vim.trim(text or "")
        if text == "" then
          return
        end
        local args = { args = text }
        if was_visual then
          -- Any positive range makes CodeCompanion treat this as operating on
          -- the visual selection (read from the '< and '> marks).
          args.range = 2
        end
        require("codecompanion").inline(args)
      end)

      vim.keymap.set({ "i", "n" }, "<Esc>", close, { buffer = buf, nowait = true })
      vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })

      vim.cmd("startinsert")
    end

    vim.keymap.set({ "n", "v" }, "<leader>o", cc_inline_prompt, { desc = "CodeCompanion inline prompt" })
  '';

  programs.nixvim.keymaps = [
    {
      key = "<leader>cc";
      mode = [ "n" "v" ];
      action = "<cmd>CodeCompanionActions<CR>";
      options.desc = "CodeCompanion actions";
    }
  ];
}

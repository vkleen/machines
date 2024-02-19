{ config, ... }:
{
  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;
        ensureInstalled = "all";
        moduleConfig = {
          highlight = {
            additional_vim_regex_highlighting = false;
            disable = config.nixvim.helpers.mkRaw /*lua*/ ''
              function(_, buf)
                  local max_filesize = 100 * 1024 -- 100 KiB
                  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                  if ok and stats and stats.size > max_filesize then
                      return true
                  end
              end
            '';
          };
        };
        incrementalSelection.enable = true;
      };
      treesitter-textobjects = {
        enable = true;
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "af" = "@function.outer";
            "if" = "@function.inner";
            "ac" = "@class.outer";
            "ic" = "@class.inner";
            "aC" = "@call.outer";
            "iC" = "@call.inner";
            "a#" = "@comment.outer";
            "i#" = "@comment.outer";
            "ai" = "@conditional.outer";
            "ii" = "@conditional.outer";
            "al" = "@loop.outer";
            "il" = "@loop.inner";
            "aP" = "@parameter.outer";
            "iP" = "@parameter.inner";
          };
          selectionModes = {
            "@parameter.outer" = "v"; # charwise
            "@function.outer" = "V"; # linewise
            "@class.outer" = "<c-v>"; # blockwise
          };
        };
        swap = {
          enable = true;
          swapNext = {
            "<leader>a" = "@parameter.inner";
          };
          swapPrevious = {
            "<leader>A" = "@parameter.inner";
          };
        };
        move = {
          enable = true;
          setJumps = true;
          gotoNextStart = {
            "]m" = "@function.outer";
            "]P" = "@parameter.outer";
          };
          gotoNextEnd = {
            "]m" = "@function.outer";
            "]P" = "@parameter.outer";
          };
          gotoPreviousStart = {
            "[m" = "@function.outer";
            "[P" = "@parameter.outer";
          };
          gotoPreviousEnd = {
            "[m" = "@function.outer";
            "[P" = "@parameter.outer";
          };
        };
        lspInterop = {
          enable = true;
          peekDefinitionCode = {
            "df" = "@function.outer";
            "dF" = "@class.outer";
          };
        };
      };
      treesitter-refactor = {
        enable = true;
        highlightCurrentScope = {
          enable = false;
        };
        highlightDefinitions = {
          enable = false;
          clearOnCursorMove = true;
        };
        smartRename = {
          enable = true;
          keymaps = {
            smartRename = "grr";
          };
        };
        navigation = {
          enable = true;
          keymaps = {
            gotoDefinition = "gnd";
            listDefinitions = "gnD";
            listDefinitionsToc = "gO";
            gotoNextUsage = "<a-*>";
            gotoPreviousUsage = "<a-#>";
          };
        };
      };
      treesitter-context = {
        enable = false;
      };
      rainbow-delimiters = {
        enable = true;
        query.default = "rainbow-parens";
        strategy.default = "global";
      };
    };
  };
}

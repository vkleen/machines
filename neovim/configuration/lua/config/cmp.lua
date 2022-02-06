local M = {}

local function rtc(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.setup()
  vim.opt.pumheight = 12

  local cmp = require"cmp"
  local luasnip = require"luasnip"
  cmp.setup{
    completion = {
      completeopt = 'menu,menuone,noinsert',
    },
    formatting = {
      format = function(entry, vim_item)
        vim_item.kind = require"lspkind".presets.default[vim_item.kind]
        vim_item.menu = ({
          luasnip = '[snip]',
          buffer = '[buffer]',
          nvim_lsp = '[lsp]',
          nvim_lua = '[lua]',
          path = '[path]',
        })[entry.source.name]

        return vim_item
      end,
    },
    mapping = {
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = false,
      }),
      ["<Tab>"] = function(fallback)
        if vim.fn.pumvisible() == 1 then
          vim.fn.feedkeys(rtc('<C-n>'), 'n')
        elseif require"luasnip".expand_or_jumpable() then
          vim.fn.feedkeys(rtc('<Plug>luasnip-expand-or-jump'), '')
        else
          fallback()
        end
      end,
      ["<S-Tab>"] = function(fallback)
        if vim.fn.pumvisible() == 1 then
          vim.fn.feedkeys(rtc('<C-p>'), 'n')
        elseif require"luasnip".expand_or_jumpable() then
          vim.fn.feedkeys(rtc('<Plug>luasnip-jump-prev'), '')
        else
          fallback()
        end
      end,
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end
    },
    sources = {
      { name = 'luasnip' },
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
      { name = 'path' },
      { name = 'buffer' },
      { name = 'crates' },
    },
  }
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' },
    }
  })
  cmp.setup.cmdline(':', {
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
      { name = 'nvim_lua' },
    }
  })
end

return M

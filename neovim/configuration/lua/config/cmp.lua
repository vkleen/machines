local M = {}

local function rtc(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function check_back_space()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local completion_helpers = {}
function completion_helpers.jump_next(fallback)
  local cmp = require"cmp"
  local luasnip = require"luasnip"
  if cmp and cmp.visible() then
    vim.fn.feedkeys(cmp.select_next_item())
  elseif luasnip.expand_or_jumpable() then
    vim.fn.feedkeys(rtc("<Plug>luasnip-expand-or-jump"), "")
  elseif check_back_space() then
    vim.fn.feedkeys(rtc("<Tab>"), "n")
  else
    fallback()
  end
end

function completion_helpers.jump_previous(fallback)
  local cmp = require"cmp"
  local luasnip = require"luasnip"
  if cmp and cmp.visible() then
    vim.fn.feedkeys(cmp.select_prev_item())
  elseif luasnip.jumpable(-1) then
    vim.fn.feedkeys(rtc("<Plug>luasnip-jump-prev"), "")
  else
    fallback()
  end
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
      ["<Tab>"] = cmp.mapping(completion_helpers.jump_next, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(completion_helpers.jump_previous, { "i", "s" }),
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

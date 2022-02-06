local M = {}

function M.do_cargo_toml_bindings()
  if vim.fn.expand('%:t') ~= 'Cargo.toml' then
    return
  end
  require"which-key".register({
    v = {
      name = 'Cargo crates',
      t = { function() require"crates".toggle() end, "Toggle version display" },
      r = { function() require"crates".reload() end, "Reload versions" },
      u = { function() require"crates".update_crate() end, "Update to newest compatible version"},
      a = { function() require"crates".update_all_crates() end, "Update all to newest compatible version"},
      U = { function() require"crates".upgrade_crate() end, "Upgrade to newest version"},
      A = { function() require"crates".upgrade_all_crates() end, "Upgrade all to newest version"},
      h = { function() require"crates".show_popup() end, "Show crates popup"},
    }
  }, { prefix = '<leader>', mode = 'n' })
  require"which-key".register({
    name = 'Cargo crates',
    u = { function() require"crates".update_crates() end, "Update to newest compatible version"},
    U = { function() require"crates".upgrade_crates() end, "Update to newest version"},
  }, { prefix = '<leader>', mode = 'v' })
end

function M.setup()
  require'crates'.setup {
    text = {
      loading    = "   Loading",
      version    = "   %s",
      prerelease = "   %s",
      yanked     = "   %s",
      nomatch    = "   No match",
      upgrade    = "   %s",
      error      = "   Error fetching crate",
    },
    popup = {
      border = "rounded", -- same as nvim_open_win config.border
      text = {
        title      = "   %s ",
        version    = "    %s ",
        prerelease = "   %s ",
        yanked     = "   %s ",
        feature    = "    %s ",
        date       = " %s ",
      },
    },
  }
  vim.api.nvim_exec([[
    autocmd FileType toml lua require"config.crates".do_cargo_toml_bindings()
  ]], false)
end

return M

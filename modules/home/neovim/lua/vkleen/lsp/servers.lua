return {
  lua_ls = {
    settings = {
      Lua = {
        codeLens = {
          enable = true,
        },
        completion = {
          callSnippet = "Replace",
        },
        doc = {
          privateName = { "^_" },
        },
        hint = {
          enable = true,
          setType = false,
          paramType = true,
          paramName = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },
  nil_ls = {},
}

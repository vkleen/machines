return {
  'ibhagwan/fzf-lua',
  dir = require('lazy-nix-helper').get_plugin_path('fzf-lua'),
  dependencies = {
    {
      'echanovski/mini.nvim',
      dir = require('lazy-nix-helper').get_plugin_path('mini.nvim'),
    }
  },
  opts = {},
  keys = {
    { '<leader>sh', function() require('fzf-lua').helptags() end, desc = '[S]earch [H]elp' },
    { '<leader>sk', function() require('fzf-lua').keymaps() end, desc = '[S]earch [K]eymaps' },
    { '<leader>sf', function() require('fzf-lua').files() end, desc = '[S]earch [F]iles' },
    { '<leader>ss', function() require('fzf-lua').builtin() end, desc = '[S]earch [S]elect fzf-lua builtin' },
    { '<leader>sw', function() require('fzf-lua').grep_cword() end, desc = '[S]earch current [W]ord' },
    { '<leader>sw', mode = 'v', function() require('fzf-lua').grep_visual() end, desc = '[S]earch Visual Selection' },
    { '<leader>sg', function() require('fzf-lua').live_grep_native() end, desc = '[S]earch by [G]rep' },
    { '<leader>sd', function() require('fzf-lua').diagnostics_workspace() end, desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', function() require('fzf-lua').resume() end, desc = '[S]earch [R]esume' },
    { '<leader>s.', function() require('fzf-lua').oldfiles() end, desc = '[S]earch Recent Files' },
    { '<leader><leader>', function() require('fzf-lua').buffers() end, desc = '[ ] Find Buffers' },
    { '<leader>/',
      function()
        require('fzf-lua').grep_curbuf()
      end,
      desc = '[/] Fuzzy find in current buffer',
    },
    { '<leader>q', function() require('fzf-lua').grep_quickfix() end, desc = 'Grep [Q]uickfix list' },
  },
}

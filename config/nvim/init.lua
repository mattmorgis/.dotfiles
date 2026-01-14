-- https://arslan.io/2023/05/10/the-benefits-of-using-a-single-init-lua-vimrc-file/

-- Settings
-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
-- Don't show the mode, since it's already in the status line
vim.o.showmode = false
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.confirm = true
vim.o.breakindent = true
vim.o.signcolumn = 'yes'
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.opt.colorcolumn = "80"
vim.o.scrolloff = 8
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.termguicolors = true
vim.o.updatetime = 250

vim.g.netrw_banner = 0

-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

if vim.fn.getenv("TERM_PROGRAM") == "ghostty" then
  vim.opt.title = true
  vim.opt.titlestring = "nvim: %{expand('%:t')}"
end

vim.opt.completeopt:append({ "menuone", "noselect", "popup", "fuzzy" })
vim.diagnostic.config({virtual_text = true})

vim.filetype.add({
  filename = {
    ['Brewfile'] = 'ruby',
  },
})

-- Keymaps

vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'move text down' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'move text up' })

-- center when navigating
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'paste without yanking' })
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", { desc = 'delete without yanking' })

-- macOS
vim.keymap.set('v', '<D-c>', '"+y', { desc = 'copy to system clipboard' })
vim.keymap.set('n', '<D-s>', ':w<CR>', { desc = 'cmd+s to save' })
vim.keymap.set('i', '<D-s>', '<C-o>:w<CR>', { desc = 'cmd+s to save' })

vim.keymap.set('n', 'j', 'gj', { desc = 'handle wrapped text' })
vim.keymap.set('n', 'k', 'gk', { desc = 'handle wrapped text' })

vim.keymap.set('i', 'jj', '<ESC>', { desc = 'exit insert on jj' })
vim.keymap.set('i', 'kk', '<ESC>', { desc = 'exit insert on kk' })

-- find and replace word under cursor
vim.keymap.set("n", "<leader>*", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Copy current [f]ile[p]ath to system clipboard (relative to git root, fallback to absolute path)
vim.keymap.set('n', '<Leader>fp', function()
  local git_prefix = vim.fn.system('git rev-parse --show-prefix'):gsub('\n', '')
  local path
  if vim.v.shell_error == 0 then
    path = git_prefix .. vim.fn.expand('%')
  else
    path = vim.fn.expand('%:p')
  end
  vim.fn.setreg('+', path)
  print('Copied to clipboard: ' .. path)
end, { silent = true })

vim.keymap.set('n', 'gK', function()
  local config = vim.diagnostic.config() or {}
  local state = (config.virtual_text and 1) or (config.virtual_lines and 2) or 0
  local next_state = (state + 1) % 3

  vim.diagnostic.config({
    virtual_text = next_state == 1,
    virtual_lines = next_state == 2
  })
end, { desc = 'Cycle diagnostic display modes' })


-- Plugins

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  {
    'nordtheme/vim',
    priority = 1000,
    config = function()
      vim.cmd [[colorscheme nord]]
    end
  },
  'lewis6991/gitsigns.nvim',
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      require('telescope').setup {
        defaults = require('telescope.themes').get_ivy(),
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require('telescope.builtin')

      -- File finding
      vim.keymap.set('n', '<C-p>', builtin.git_files, {})
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })

      -- Text search
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })

      -- Git operations
      vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = '[G]it [B]ranches' })
      vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = '[G]it [C]ommits' })
      vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = '[G]it [S]tatus' })

      -- Others
      vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[S]earch [B]uffers' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    end,
  },
  -- Highlight, edit, and navigate code
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects'
    },
    branch = 'master',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'css',
        'diff',
        'html',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'ruby',
        'terraform',
        'toml',
        'typescript',
        'vim',
        'vimdoc',
        'yaml'
      },
      auto_install = false,
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = ",",        -- maps in normal mode to init the node/scope selection with space
          node_incremental = ",",      -- increment to the upper named parent
          node_decremental = "<bs>",   -- decrement to the previous node
          scope_incremental = "<tab>", -- increment to the upper scope
        },
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      textobjects = {
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']]'] = '@function.outer',
          },
          goto_next_end = {
            [']['] = '@function.outer',
          },
          goto_previous_start = {
            ['[['] = '@function.outer',
          },
          goto_previous_end = {
            ['[]'] = '@function.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>sn'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>sp'] = '@parameter.inner',
          },
        },
      },
    },
  },
  -- Show current context
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = "nvim-treesitter",
    config = function()
      require("treesitter-context").setup({
        enable = true,
        multiwindow = false,
        max_lines = 0,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = "outer",
        mode = "cursor",
        separator = nil,
        zindex = 20,
        on_attach = nil,
      })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        formatting = {
          expandable_indicator = true,
          format = function(entry, item)
            local menu = {
              nvim_lsp = "[LSP]",
              buffer = "[buffer]",
              path = "[path]"
            }
            item.menu = menu[entry.source.name]
            return item
          end
        },
        mapping = cmp.mapping.preset.insert({
          -- completions
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ['<C-Space>'] = cmp.mapping.complete(),

          -- move through snippets
          ['<C-k>'] = cmp.mapping(function(fallback)
            if vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-j>'] = cmp.mapping(function(fallback)
            if vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        },
        -- performance = {
        --   max_view_entries = 20,
        -- },
      })
    end,
  }
})

-- Autocmds

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup('HighlightYank', {})

autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = yank_group,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- LSP Setup
autocmd('LspAttach', {
  group = augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
    map('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gt', vim.lsp.buf.type_definition, '[G]oto [T]ype Definition')
    map('[d', function() vim.diagnostic.jump({ count = -1 }) end, 'Previous Diagnostic')
    map(']d', function() vim.diagnostic.jump({ count = 1 }) end, 'Next Diagnostic')

    map('K', vim.lsp.buf.hover, 'Hover Documentation')

    -- Code actions and refactoring
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

    -- Format
    map('<leader>f', vim.lsp.buf.format, '[F]ormat')

    -- native completions:
    -- opted for nvm-cmp for now
    -- local client = vim.lsp.get_client_by_id(event.data.client_id)
    --   if client then
    --     vim.lsp.completion.enable(true, client.id, event.buf, {
    --       autotrigger = true,
    --     })
    -- end
  end,
})

local servers = {
  'clangd','lua_ls'
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()

for _, server in ipairs(servers) do
  vim.lsp.config(server, { capabilities = capabilities })
  vim.lsp.enable(server)
end

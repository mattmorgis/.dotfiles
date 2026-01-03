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

-- Autocmds

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local personal_group = augroup('personal', {})
local yank_group = augroup('HighlightYank', {})

autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = yank_group,
  callback = function()
    vim.hl.on_yank()
  end,
})

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
    'shaunsingh/nord.nvim',
    config = function()
      vim.g.nord_italic = false
      vim.g.nord_bold = false
      vim.cmd [[colorscheme nord]]
    end
  },
  'lewis6991/gitsigns.nvim',
  'numToStr/Comment.nvim',
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
      -- { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
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
})

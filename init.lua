vim.cmd[[colorscheme habamax]]
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.clipboard      = { "unnamed", "unnamedplus" }
vim.opt.tabstop        = 4               -- tab == 2 spaces
vim.opt.shiftwidth     = 4               -- indent size
vim.opt.expandtab      = true            -- tab becomes spaces
-- vim.opt.softtabstop = 2               -- WHAT THE FUCK DOES THIS MEAN?

-- Save and return to Normal mode from Insert mode
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>', { noremap = true, silent = true })
-- Save and return to Normal mode from Visual mode
vim.keymap.set('v', '<C-s>', '<Esc>:w<CR>', { noremap = true, silent = true })
-- Save in Normal mode
vim.keymap.set('n', '<C-s>', ':w<CR>',      { noremap = true, silent = true })

-- Normal Mode: Delete inner word
vim.keymap.set('n', '<C-H>', 'diw',         { noremap = true })
vim.keymap.set('n', '<C-BS>', 'diw',        { noremap = true })
-- Insert Mode: Delete word backward
vim.keymap.set('i', '<C-H>', '<C-w>',       { noremap = true })
vim.keymap.set('i', '<C-BS>', '<C-w>',      { noremap = true })
-- Command-line Mode: Delete word backward
vim.keymap.set('c', '<C-H>', '<C-w>',       { noremap = true })
vim.keymap.set('c', '<C-BS>', '<C-w>',      { noremap = true })

-- Normal Mode: Undo
vim.keymap.set('n', '<C-z>', 'u',           { noremap = true })
-- Insert Mode: Undo (returns to normal mode, undos, then back to insert)
vim.keymap.set('i', '<C-z>', '<C-o>u',      { noremap = true })
-- Visual Mode: Undo
vim.keymap.set('v', '<C-z>', '<Esc>ugv',    { noremap = true })

-- Normal Mode: Redo
vim.keymap.set('n', '<C-y>', '<C-r>',       { noremap = true })
-- Insert Mode: Redo (uses <C-o> to run one normal command)
vim.keymap.set('i', '<C-y>', '<C-o><C-r>',  { noremap = true })
-- Visual Mode: Redo
vim.keymap.set('v', '<C-y>', '<Esc><C-r>gv',{ noremap = true })

-- Select All
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select all' })      -- Normal mode
vim.keymap.set('i', '<C-a>', '<Esc>ggVG', { desc = 'Select all' }) -- Insert mode

-- Normal mode: Ctrl-f opens the search prompt
vim.keymap.set('n', '<C-f>', '/', { desc = 'Search in buffer' })

-- Insert mode: Ctrl-f exits to normal mode and opens search
vim.keymap.set('i', '<C-f>', '<Esc>/', { desc = 'Search in buffer' })

-- Clear search highlights with <Esc>
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end 
   
vim.opt.rtp:prepend(lazypath)
vim.g.VM_maps = {
  ['Add Cursor At Pos']   = '<A-CR>',
  ['Add Cursor Down']     = '<A-Down>',
  ['Add Cursor Up']       = '<A-Up>',
}   
  
require("lazy").setup({
  
    { 'mg979/vim-visual-multi' },

    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    { "p00f/clangd_extensions.nvim" },
    
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
    },

    { "hrsh7th/nvim-cmp" },         -- The completion engine
    { "hrsh7th/cmp-nvim-lsp" },     -- LSP source for nvim-cmp
    { "L3MON4D3/LuaSnip" },         -- Snippet engine (required)
    { "saadparwaiz1/cmp_luasnip" }, -- Snippet source for nvim-cmp

    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
    { "theHamsta/nvim-dap-virtual-text", opts = {} },
})  

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })

-- vim.keymap.set("n", "n", vim.diagnostic.goto_next,   { remap = false,   desc = "Go to next diagnostic" })
-- vim.keymap.set("n", "S-n", vim.diagnostic.goto_prev, { remap = false, desc = "Go to previous diagnostic" })

local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept completion with Enter
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- This is the one that gets data from clangd
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})


require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "clangd",
        "lua_ls",
    },
    automatic_installation = true,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }, -- Stops the "Undefined global vim" warning
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
})

vim.lsp.config("clangd", {
  -- Add any clangd-specific settings here if needed
})

vim.lsp.enable({ "lua_ls", "clangd" })

local dap = require("dap")
local dapui = require("dapui")

-- Setup UI
dapui.setup()

-- Automatically open/close the UI when debugging starts/ends
dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

-- GDB Adapter Configuration
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--quiet", "--interpreter=dap" },
}

-- C/C++/Rust Configuration
dap.configurations.cpp = {
  {
    name = "Run GDB",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
}
dap.configurations.c = dap.configurations.cpp

-- Debugger Keymaps
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = "Debug: Start/Continue" })
vim.keymap.set('n', '<leader>n', function() require('dap').step_over() end, { desc = "Debug: Step Over" })
vim.keymap.set('n', '<leader>s', function() require('dap').step_into() end, { desc = "Debug: Step Into" })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })


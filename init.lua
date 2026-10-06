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
    
    {
        "microsoft/vscode-js-debug",
        version = "1.x", -- Highly recommended to pin to the 1.x branch
        build = "npm i && npx gulp vsDebugServerBundle && mv dist out",
    },

    {
      "mxsdev/nvim-dap-vscode-js",
      dependencies = { "mfussenegger/nvim-dap" },
      opts = {
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { 'pwa-node', 'pwa-chrome', 'node-terminal' },
      }
    },
    
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            -- NOTE: this plugin is on the `main` branch (new API), so
            -- parsers are installed with `install{}` instead of `TSInstall`.
            local ts = require("nvim-treesitter")
            ts.setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            -- C# (c_sharp) is what powers highlighting + indentation for .cs
            local parsers = {
                "c_sharp",  -- C#
                "c", "cpp",
                "lua", "vim", "vimdoc", "query",
                "json", "markdown", "markdown_inline",
                "bash", "python", "go", "rust",
                "toml", "yaml", "html", "css",
                "glsl",
            }
            ts.install(parsers)

            -- Only turn on treesitter highlighting for filetypes we have a
            -- parser for, instead of blindly calling start() everywhere.
            vim.api.nvim_create_autocmd("FileType", {
                pattern = parsers,
                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },
})  

-- ---------------------------------------------------------------------------
-- C# / .NET support
-- ---------------------------------------------------------------------------

-- Roslyn (roslyn_ls) is the C# language server. It already ships good defaults
-- in nvim-lspconfig, so we only tweak the bits that matter day to day.
vim.lsp.config("roslyn_ls", {
    settings = {
        ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_types = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
        },
        ['csharp|formatting'] = {
            -- Let the server own formatting decisions.
            enable = true,
            organize_imports_on_format = true,
        },
        ['csharp|symbol_search'] = {
            dotnet_search_reference_assemblies = true,
        },
    },
})

-- C# buffer-local options. Roslyn handles formatting, but indentation still
-- comes from the editor, so pin it to 4 spaces like dotnet/csharpier do.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "cs",
    callback = function(args)
        local o = vim.bo[args.buf]
        o.shiftwidth = 4
        o.tabstop = 4
        o.expandtab = true
        o.softtabstop = 4
        o.smartindent = false
        o.cindent = false
        o.autoindent = true
        o.formatoptions = "j"   -- do not let Vim reflow C# comments
        o.comments = "s1:*/*,mb:*,ex:*/,://"
        -- No `matchpairs` override: the old `gmatch` option was removed from
        -- Neovim, and Vim's default "(:),{:},[:]" already suits C# braces.
        o.iskeyword = "@,48-57,_,192-255"
        o.omnifunc = "v:lua.vim.lsp.omnifunc"
    end,
})

-- `.sln`/`.csproj` are plain XML; give them a friendlier filetype + syntax.
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sln", "csproj" },
    callback = function(args)
        vim.bo[args.buf].commentstring = "<!-- %s -->"
    end,
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
        "ts_ls" ,
        "ols" ,
        "roslyn_ls", -- C# (needs the .NET SDK/runtime on $PATH)
        --"vtsls",
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
})

-- vim.lsp.config("vtsls", {
-- })

-- NOTE: the server is `ts_ls` (TypeScript). It used to be typo'd as `ls_ts`
-- here, which silently meant the TS/JS language server never started.
vim.lsp.config("ts_ls", {
})

-- GLSL language server (nolanderc/glsl_analyzer, binary in ~/.local/bin)
vim.lsp.config("glsl_analyzer", {
})

vim.lsp.enable({ 
    "lua_ls", 
    "clangd", 
    "ols" ,
    --"vtsls",
    "ts_ls",
    "roslyn_ls",
    "glsl_analyzer",
})

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
    name = "Launch (GDB)",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    args = function()
      return vim.fn.input('Args: ')
    end,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
  {
    name = "Launch with stdin (GDB)",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    args = function()
      local s = vim.fn.input('Args: ')
      local stdin = vim.fn.input('Redirect stdin from file (empty to skip): ')
      if stdin ~= '' and s ~= '' then
        return s .. ' < ' .. stdin
      elseif stdin ~= '' then
        return '< ' .. stdin
      end
      return s
    end,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
}

local js_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

for _, language in ipairs(js_languages) do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (Node)",
      program = "${file}",
      args = function()
        local s = vim.fn.input('Args: ')
        if s == '' then return {} end
        return vim.split(s, '%s+')
      end,
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug current test file",
      runtimeExecutable = "npx",
      runtimeArgs = { "tsx", "--test" },
      program = "${file}",
      cwd = vim.fn.getcwd(),
      autoAttachChildProcesses = true,
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug all tests (npm test)",
      runtimeExecutable = "npm",
      runtimeArgs = { "run", "test" },
      cwd = vim.fn.getcwd(),
      autoAttachChildProcesses = true,
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to Process (Linux PID)",
      processId = require'dap.utils'.pick_process,
      cwd = "${workspaceFolder}",
    },
  }
end

dap.configurations.c = dap.configurations.cpp

-- C# / .NET debugging via SharpDbg (installed by Mason).
-- It needs an already-built binary, so run `dotnet build` first.
-- NOTE: `netcoredbg` is no longer published on nuget.org, hence SharpDbg.
dap.adapters.sharpdbg = {
  type = "executable",
  command = "sharpdbg",
  args = { "--interpreter=vscode" },
}

-- Build a project, then debug the produced assembly.
local function dotnet_build()
  vim.fn.system({ "dotnet", "build", "-v", "q", "--nologo" })
end

dap.configurations.cs = {
  {
    name = "Build & Launch (current project)",
    type = "sharpdbg",
    request = "launch",
    program = function()
      dotnet_build()
      return vim.fn.input("Assembly path: ", vim.fs.joinpath(vim.fn.getcwd(), "bin/Debug/net10.0/"), "file")
    end,
    cwd = "${workspaceFolder}",
    stopAtEntry = false,
    console = "internalConsole",
  },
  {
    name = "Launch (pick assembly)",
    type = "sharpdbg",
    request = "launch",
    program = function()
      return vim.fn.input("Assembly path: ", vim.fn.getcwd() .. "/", "file")
    end,
    args = function()
      local s = vim.fn.input("Args: ")
      if s == '' then return {} end
      return vim.split(s, '%s+')
    end,
    cwd = "${workspaceFolder}",
    stopAtEntry = false,
    console = "internalConsole",
  },
  {
    name = "Attach to process",
    type = "sharpdbg",
    request = "attach",
    processId = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}

-- Debugger Keymaps
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = "Debug: Start/Continue" })
vim.keymap.set('n', '<leader>n', function() require('dap').step_over() end, { desc = "Debug: Step Over" })
vim.keymap.set('n', '<leader>s', function() require('dap').step_into() end, { desc = "Debug: Step Into" })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })

-- C# convenience keymaps
vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end,
  { desc = "Format buffer (C#: dotnet format on save)" })
vim.keymap.set('n', '<leader>li', function() vim.lsp.codelens.run() end, { desc = "Codelens refresh" })
vim.keymap.set('n', '<leader>ld', function() vim.diagnostic.open_float() end, { desc = "Line diagnostics" })
vim.keymap.set('n', '<leader>lr', function() vim.lsp.buf.code_action() end, { desc = "Code action" })
vim.keymap.set('n', '<leader>qn', function()
  vim.diagnostic.setloclist()
  vim.cmd("lopen")
end, { desc = "Diagnostics in quickfix/loclist" })

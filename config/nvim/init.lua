-- Bind vim clipboard to system clipboard
vim.cmd('set clipboard+=unnamedplus')

-- If we're using the VSCode Extension
if vim.g.vscode == 1 then
  -- Make j and k travese folds
  vim.api.nvim_set_keymap('n', 'j', 'gj', {silent = true})
  vim.api.nvim_set_keymap('n', 'k', 'gk', {silent = true})
else
  -- Call vim plug to init extensions 
  vim.cmd(
  [[
  call plug#begin("~/.config/nvim/plugged")
  Plug 'joshdick/onedark.vim'
  Plug 'itchyny/lightline.vim'
  Plug 'junegunn/goyo.vim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-lua/completion-nvim'
  call plug#end()
  ]]
  )
  --
  -- 256 terminal colors
  if vim.fn.has('termguicolors') == 1 then
    vim.o.termguicolors = true
  end
  -- Onedark colorscheme
  --
  -- Set the status bar to onedark
  vim.g.lightline = {colorscheme = 'onedark'}
  -- Hide squigglies
  vim.g.onedark_hide_endofbuffer = 1
  -- Enable italics
  vim.g.onedark_terminal_italics = 1
  -- Enable syntax highlighting
  vim.cmd('syntax on')
  -- Finally set colorscheme to Onedark
  vim.cmd('autocmd vimenter * ++nested colorscheme onedark')
  -- Set tabs to spaces, two spaces, and other tab features
  -- vim.o.tabstop = 2
  vim.cmd('set expandtab')
  vim.cmd('set shiftwidth=2')
  vim.cmd('set softtabstop=2')
  -- vim.o.expandtab = true
  -- vim.o.shiftwidth = 2
  -- vim.o.softtabstop = 2
  -- Tabbing mid space keeps indentation
  vim.o.smarttab = true
  -- Copy level of indendation from previous line
  vim.o.autoindent = true
  -- Search to ignorecase unless we put in cases, highligh search
  vim.o.incsearch = true
  vim.o.ignorecase = true
  vim.o.smartcase = true
  vim.o.hlsearch = true
  -- Enable wrapping and breaking of indent
  vim.o.wrap = true
  vim.o.breakindent = true
  -- Markdown settings
  vim.cmd('autocmd FileType markdown setlocal shiftwidth=2 tabstop=2 softtabstop=2')
  vim.g.vim_markdown_folding_disabled = true
  -- Necessary binds tbh
  vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('i', 'jk', '<Esc>', {})
  -- Save on edit
  -- vim.cmd('autocmd TextChanged,TextChangedI <buffer> silent write')
  -- Syntax highlighting of embedded stuff
  vim.g.vimsyn_embed = 'l'

  local lspconfig = require'lspconfig'
  local configs = require 'lspconfig/configs'
  local util = require 'lspconfig/util'

  configs.rust_analyzer = {
    default_config = {
      cmd = {"rust-analyzer"};
      filetypes = {"rust"};
      root_dir = util.root_pattern("Cargo.toml", "rust-project.json");
      settings = {
        ["rust-analyzer"] = {
          ["cargo"] = {
            ["allFeatures"] = true
          }
        }
      };
    };
    docs = {
      package_json = "https://raw.githubusercontent.com/rust-analyzer/rust-analyzer/master/editors/code/package.json";
      description = [[
      https://github.com/rust-analyzer/rust-analyzer
      rust-analyzer (aka rls 2.0), a language server for Rust
      See [docs](https://github.com/rust-analyzer/rust-analyzer/tree/master/docs/user#settings) for extra settings.
      ]];
      default_config = {
        root_dir = [[root_pattern("Cargo.toml", "rust-project.json")]];
      };
    };
  };
  -- vim:et ts=2 sw=2
  lspconfig.rust_analyzer.setup{}

  local server_name = "tsserver"
  local bin_name = "typescript-language-server"
  if vim.fn.has('win32') == 1 then
    bin_name = bin_name..".cmd"
  end

  configs[server_name] = {
    default_config = {
      cmd = {bin_name, "--stdio"};
      filetypes = {"javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx"};
      root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git");
    };
    docs = {
      description = [[
      https://github.com/theia-ide/typescript-language-server
      `typescript-language-server` depends on `typescript`. Both packages can be installed via `npm`:
      ```sh
      npm install -g typescript typescript-language-server
      ```
      ]];
      default_config = {
        root_dir = [[root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")]];
      };
    };
  }
  -- vim:et ts=2 sw=2

  lspconfig.tsserver.setup{}

  -- Relative line numbers
  vim.cmd('set rnu')

  -- Hides buffers? idk
  vim.o.hidden = true
  -- Basically VSCode save after delay
  vim.cmd('set updatetime=300')
  -- Put the errors on the signcolumn so the entire file view isn't indented
  vim.cmd('set signcolumn=number')

  -- More lsp config
  -- c-] to view definition
  vim.api.nvim_buf_set_keymap(0, 'n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
  -- K to 'hover'
  vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
  -- gD to check the implementation 
  vim.api.nvim_buf_set_keymap(0, 'n', 'gD', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true})
  -- c-k to help signature
  vim.api.nvim_buf_set_keymap(0, 'n', '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', {noremap = true})
  -- 1gD to check type definition
  vim.api.nvim_buf_set_keymap(0, 'n', '1gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', {noremap = true})
  -- gr to check references
  vim.api.nvim_buf_set_keymap(0, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', {noremap = true})
  -- g0 to check document symbol
  vim.api.nvim_buf_set_keymap(0, 'n', 'g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', {noremap = true})
  -- gW to check workspace symbol
  vim.api.nvim_buf_set_keymap(0, 'n', 'gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', {noremap = true})
  -- gd to check declaration
  vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', {noremap = true})

  vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

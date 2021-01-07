-- Bind vim clipboard to system clipboard
vim.cmd('set clipboard+=unnamedplus')

-- If we're using the VSCode Extension
if vim.g.vscode == 1 then
  -- Make j and k travese folds
  vim.api.nvim_set_keymap('n', 'j', 'gj', {silent = true})
  vim.api.nvim_set_keymap('n', 'k', 'gk', {silent = true})
else

  -- <==PLUGINS==>
  -- 
  -- Call vim plug to init extensions 
  -- TODO figure out some better way to put vim-plug in init.lua
  vim.cmd(
  [[
  call plug#begin("~/.config/nvim/plugged")
  Plug 'joshdick/onedark.vim'
  Plug 'itchyny/lightline.vim'
  Plug 'junegunn/goyo.vim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-lua/completion-nvim'
  Plug 'nvim-lua/lsp-status.nvim'
  call plug#end()
  ]]
  )

  -- <==COLOR SCHEME==> && <==Onedark Config==>
  --
  -- If we're in a terminal then we gotta limit out colors to 256 bit
  if vim.fn.has('termguicolors') == 1 then
    vim.o.termguicolors = true
  end
  -- Set the status bar to Onedark
  vim.g.lightline = {colorscheme = 'onedark'}
  -- Hide squiggly lines at the end of file
  vim.g.onedark_hide_endofbuffer = 1
  -- Enable italic font
  vim.g.onedark_terminal_italics = 1
  -- Enable syntax highlighting in nvim
  vim.cmd('syntax on')
  -- Set colorscheme to onedark
  vim.cmd('autocmd vimenter * ++nested colorscheme onedark')
  -- Syntax highlighting of embedded code
  vim.g.vimsyn_embed = 'l'

  -- <==MECHANICS==>
  --
  -- Set tabs to spaces, tabs two spaces wide
  vim.cmd('set expandtab')
  vim.cmd('set shiftwidth=2')
  vim.cmd('set softtabstop=2')
  -- Setting these tab configs directly in init.lua doesn't work for some reason
  -- vim.o.expandtab = true
  -- vim.o.shiftwidth = 2
  -- vim.o.softtabstop = 2
  --
  -- Tabbing mid space keeps indentation
  vim.o.smarttab = true
  -- Copy level of indendation from previous line
  vim.o.autoindent = true
  -- Search incrementally, live results as we type
  vim.o.incsearch = true
  -- Ignorecase in search unless we put in cases
  vim.o.ignorecase = true
  vim.o.smartcase = true
  -- Highligh search results
  vim.o.hlsearch = true
  -- Enable wrapping and breaking of indent
  vim.o.wrap = true
  vim.o.breakindent = true
  -- Make it so we can easily traverse word wrappings
  vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true, silent = true })
  -- JK for escape
  vim.api.nvim_set_keymap('i', 'jk', '<Esc>', {})
  -- Save on edit (very buggy, use with caution especially with LSPs)
  -- vim.cmd('autocmd TextChanged,TextChangedI <buffer> silent write')

  -- <==LANGUAGE SERVER PROTOCOL CONFIGURATION==>
  local lspconfig = require 'lspconfig'
  local configs = require 'lspconfig/configs'
  local util = require 'lspconfig/util'
  local lsp = vim.lsp

  -- <==RUST==>
  configs.rust_analyzer = {
    default_config = {
      cmd = {"rust-analyzer"};
      filetypes = {"rust"};
      root_dir = util.root_pattern("Cargo.toml", "rust-project.json");
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true
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

  -- <==TYPESCRIPT==>
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

  -- <==LATEX==>
  local texlab_build_status = vim.tbl_add_reverse_lookup {
    Success = 0;
    Error = 1;
    Failure = 2;
    Cancelled = 3;
  }
  local texlab_forward_status = vim.tbl_add_reverse_lookup {
    Success = 0;
    Error = 1;
    Failure = 2;
    Unconfigured = 3;
  }
  local function buf_build(bufnr)
    bufnr = util.validate_bufnr(bufnr)
    local params = { textDocument = { uri = vim.uri_from_bufnr(bufnr) }  }
    lsp.buf_request(bufnr, 'textDocument/build', params,
    function(err, _, result, _)
      if err then error(tostring(err)) end
      print("Build "..texlab_build_status[result.status])
    end)
  end
  local function buf_search(bufnr)
    bufnr = util.validate_bufnr(bufnr)
    local params = { textDocument = { uri = vim.uri_from_bufnr(bufnr) }, position = { line = vim.fn.line('.')-1, character = vim.fn.col('.')  }}
    lsp.buf_request(bufnr, 'textDocument/forwardSearch', params,
    function(err, _, result, _)
      if err then error(tostring(err)) end
      print("Search "..texlab_forward_status[result.status])
    end)
  end
  -- bufnr isn't actually required here, but we need a valid buffer in order to
  -- be able to find the client for buf_request.
  -- TODO find a client by looking through buffers for a valid client?
  -- local function build_cancel_all(bufnr)
  --   bufnr = util.validate_bufnr(bufnr)
  --   local params = { token = "texlab-build-*" }
  --   lsp.buf_request(bufnr, 'window/progress/cancel', params, function(err, method, result, client_id)
  --     if err then error(tostring(err)) end
  --     print("Cancel result", vim.inspect(result))
  --   end)
  -- end
  configs.texlab = {
    default_config = {
      cmd = {"texlab"};
      filetypes = {"tex", "bib"};
      root_dir = vim.loop.os_homedir;
      settings = {
        latex = {
          build = {
            -- pvc is added to continously compile file on change
            -- can view pdf using zathura
            -- sudo dnf install zathura zathura-plugins-all
            -- then add `$pdf_previewer = 'start zathura';` to `~/.latexmkrc`
            args = {"-pvc", "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f"};
            -- we're using latexmk because I haven't been able to figure out tectonic yet
            executable = "latexmk";
            onSave = true;
          };
          forwardSearch = {
            args = {};
            executable = nil;
            onSave = false;
          };
          lint = {
            onChange = true;
          };
        };
        bibtex = {
          formatting = {
            lineLength = 120
          };
        };
      };
    };
    commands = {
      TexlabBuild = {
        function()
          buf_build(0)
        end;
        description = "Build the current buffer";
      };
      TexlabForward = {
        function()
          buf_search(0)
        end;
        description = "Forward search from current position";
      }
    };
    docs = {
      description = [[
      https://texlab.netlify.com/
      A completion engine built from scratch for (La)TeX.
      See https://texlab.netlify.com/docs/reference/configuration for configuration options.
      ]];
      default_config = {
        root_dir = "vim's starting directory";
      };
    };
  }
  configs.texlab.buf_build = buf_build
  configs.texlab.buf_search = buf_search
  -- vim:et ts=2 sw=2
  lspconfig.texlab.setup{}

  -- Relative line numbers
  vim.cmd('set rnu')

  -- Hides buffers? idk
  vim.o.hidden = true
  -- After cursor doesn't move for .3 seconds pop def
  vim.cmd('set updatetime=300')
  vim.cmd('autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()')
  -- Put the errors on the signcolumn so the entire file view isn't indented
  vim.cmd('set signcolumn=number')

  -- <==LSP KEYBINDS==>
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
  -- Autocomplete w/ Ctrl-x Ctrl-o
  vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

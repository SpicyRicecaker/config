-- Bind vim clipboard to system clipboard
vim.o.clipboard = 'unnamedplus'

-- If we're using the VSCode Extension
if vim.g.vscode == 1 then
  -- Make j and k travese folds
  vim.api.nvim_set_keymap('n', 'j', 'gj', {silent = true})
  vim.api.nvim_set_keymap('n', 'k', 'gk', {silent = true})
else
  require'plugins'
  -- <==ALIASES==>
  --
  local cmd = vim.cmd
  -- local fn = vim.fn
  local g = vim.g

  -- <==UTIL==>
  --
  -- Need to use this workaround to set options until simpler option interface is made in master
  -- You need to set the global variable, as well as either window or buffer variable to make sure everything works
  -- Look in nvim help options to check the scope of each option
  local scopes = {b = {vim.o, vim.bo}, w = {vim.o, vim.wo}}

  -- Scope, key, value
  local function opt (s, k, v)
    for _, scope in pairs(scopes[s]) do
      scope[k]=v
    end
  end

  -- <==PLUGINS==>
  --
  -- Call vim plug to init extensions
  -- TODO figure out some better way to put vim-plug in init.lua

  -- <==COLOR SCHEME==> && <==Onedark Config==>
  --
  -- If we're in a terminal then we gotta limit out colors to 256 bit
  if vim.fn.has('termguicolors') == 1 then
    vim.o.termguicolors = true
  end
  -- Set the status bar to Onedark
  g.lightline = {colorscheme = 'onedark'}
  -- Hide squiggly lines at the end of file
  g.onedark_hide_endofbuffer = 1
  -- Enable italic font
  g.onedark_terminal_italics = 1
  -- Enable syntax highlighting in nvim
  cmd'syntax on'
  -- Set colorscheme to onedark
  cmd'autocmd vimenter * ++nested colorscheme onedark'
  -- Syntax highlighting of embedded code
  g.vimsyn_embed = 'l'

  -- <==MECHANICS==>
  --
  -- Tab options
  --
  -- Set tabs to spaces, tabs two spaces wide
  local indent = 2
  opt('b', 'expandtab', true)                           -- Use spaces instead of tabs
  opt('b', 'shiftwidth', indent)                        -- Size of an indent
  opt('b', 'smartindent', true)                         -- Insert indents automatically
  opt('b', 'tabstop', indent)
  -- Tabbing mid space keeps indentation
  vim.o.smarttab = true
  -- Copy level of indendation from previous line
  vim.o.autoindent = true

  -- Search options

  -- Search incrementally, live results as we type
  vim.o.incsearch = true
  -- Ignorecase in search unless we put in cases
  vim.o.ignorecase = true
  vim.o.smartcase = true
  -- Highligh search results
  vim.o.hlsearch = true

  -- Text

  -- Enable wrapping and breaking of indent
  vim.o.wrap = true
  vim.o.breakindent = true

  -- Gutter

  -- Relative line numbers
  opt('w', 'rnu', true)
  -- But show current line number
  opt('w', 'number', true)
  -- Have errors show on the number column
  opt('w', 'scl', 'number')

  -- Misc

  -- Using join space J inserts no double spaces after a dot
  vim.o.joinspaces = false
  -- Make it so we can easily traverse word wrappings
  vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true, silent = true })
  -- JK for escape
  vim.api.nvim_set_keymap('i', 'jk', '<Esc>', {})
  -- Neovim nightly feature to briefly show highlight on yank
  cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'

  -- Language Server QOL Changes

  -- Allow modified buffers? idk
  vim.o.hidden = true
  -- Update time (ms) used for time before cursor hold event is triggered and swap is saved to disk
  vim.o.ut = 300
  -- Show diagnostics on mouse hold
  -- Also AUTOWRITE file!!! so I don't break my pinkie spamming :wq everytime I want to see rust-analyzer diagnostics thanks
  cmd'autocmd TextChanged,TextChangedI <buffer> silent write'
  cmd'autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()'

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

  -- <==LUA==>
  local name = "sumneko_lua"
  configs[name] = {
    default_config = {
      filetypes = {'lua'};
      root_dir = function(fname)
        return util.find_git_ancestor(fname) or util.path.dirname(fname)
      end;
      log_level = vim.lsp.protocol.MessageType.Warning;
    };
    docs = {
      package_json = "https://raw.githubusercontent.com/sumneko/vscode-lua/master/package.json";
      description = [[
      https://github.com/sumneko/lua-language-server
      Lua language server.
      `lua-language-server` can be installed by following the instructions [here](https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)).
      **By default, lua-language-server doesn't have a `cmd` set.** This is because nvim-lspconfig does not make assumptions about your path. You must add the following to your init.vim or init.lua to set `cmd` to the absolute path ($HOME and ~ are not expanded) of you unzipped and compiled lua-language-server.
      ```lua
      local system_name
      if vim.fn.has("mac") == 1 then
        system_name = "macOS"
      elseif vim.fn.has("unix") == 1 then
        system_name = "Linux"
      elseif vim.fn.has('win32') == 1 then
        system_name = "Windows"
      else
        print("Unsupported system for sumneko")
      end
      -- set the path to the sumneko installation; if you previously installed via the now deprecated :LspInstall, use
      local sumneko_root_path = vim.fn.stdpath('cache')..'/lspconfig/sumneko_lua/lua-language-server'
      local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"
      require'lspconfig'.sumneko_lua.setup {
        cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
              -- Setup your lua path
              path = vim.split(package.path, ';'),
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = {'vim'},
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = {
                [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
              },
            },
          },
        },
      }
      ```
      ]];
      default_config = {
        root_dir = [[root_pattern(".git") or bufdir]];
      };
    };
  }
  local system_name
  if vim.fn.has("mac") == 1 then
    system_name = "macOS"
  elseif vim.fn.has("unix") == 1 then
    system_name = "Linux"
  elseif vim.fn.has('win32') == 1 then
    system_name = "Windows"
  else
    print("Unsupported system for sumneko")
  end
  -- set the path to the sumneko installation; if you previously installed via the now deprecated :LspInstall, use
  local sumneko_root_path = '/home/spicy/build/lua-language-server'
  local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"
  lspconfig.sumneko_lua.setup {
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = vim.split(package.path, ';'),
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {'vim'},
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
          },
        },
      },
    },
  }
  -- vim:et ts=2

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

  -- <==TREESITTER (SYNTAX HIGHLIGHTING)==>
  require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
      enable = true,              -- false will disable the whole extension
      -- disable = { "c", "rust" },  -- list of language that will be disabled
    },
  }
end

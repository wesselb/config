-- Set executables and paths:
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/nvim/bin/python")
local todo_py_path = vim.fn.expand("~/Dropbox/Projects/PyLib/config/todo.py")

-- Parse `--no-tree` argument.
local no_tree = vim.env.NVIM_NO_TREE == "1"

-- Leader:
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic options:
local opt = vim.opt
local map = vim.keymap.set

opt.encoding = "utf-8"
opt.number = true
opt.background = "light"
opt.fileformat = "unix"

opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.expandtab = true
opt.autoindent = true

opt.colorcolumn = "88"
opt.textwidth = 0

opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

opt.mouse = "a"
opt.foldenable = false

-- Better wrapped-line movement:
map({ "n", "x" }, "j", "gj")
map({ "n", "x" }, "k", "gk")

-- Spacemacs-like window shortcuts:
map("n", "<leader>s", ":nohlsearch<CR>", { silent = true })
map("n", "<leader>q", ":q<CR>", { silent = true })
map("n", "<leader>fs", ":w<CR>", { silent = true })
map("n", "<leader>w", "<C-w>", { remap = true })
map("n", "<leader>wd", "<C-w>q", { silent = true })
map("n", "<leader>w-", ":sp<CR>", { silent = true })
map("n", "<leader>w/", ":vsp<CR>", { silent = true })

map("n", "<leader>l", ":lclose<CR>", { silent = true })

-- Per-filetype color column:
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.py",
	callback = function()
		vim.opt_local.colorcolumn = "88"
	end,
})

-- Bootstrap `lazy.nvim`.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ "tpope/vim-sleuth" },

	{
		"maxmx03/solarized.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"kylechui/nvim-surround",
		version = "^4.0.0",
		config = true,
	},

	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()

			-- Toggle comments in normal mode
			map("n", "<leader>c", function()
				require("Comment.api").toggle.linewise.current()
			end, { silent = true })

			-- Toggle comments in visual mode
			map(
				"v",
				"<leader>c",
				"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
				{ silent = true }
			)
		end,
	},

	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				view = { width = 35 },
				renderer = { group_empty = true },
				filters = { dotfiles = false },
				update_focused_file = { enable = true },
			})

			-- Automatically open whenever `nvim` is opened.
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					if no_tree then
						return
					end
					require("nvim-tree.api").tree.open()
					vim.cmd("wincmd p")
				end,
			})

			-- Exit whenever it is the last remaining window.
			vim.api.nvim_create_autocmd("BufEnter", {
				nested = true,
				callback = function()
					local tab = vim.api.nvim_get_current_tabpage()
					local wins = vim.api.nvim_tabpage_list_wins(tab)
					if #wins ~= 1 then
						return
					end

					local buf = vim.api.nvim_win_get_buf(wins[1])
					if vim.bo[buf].filetype == "NvimTree" then
						vim.cmd.quit()
					end
				end,
			})
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = {
						"^.git/",
						"/.git/",
						"^.nox/",
						"/.nox/",
						"^.mypy_cache/",
						"/.mypy_cache/",
						"^.ruff_cache/",
						"/.ruff_cache/",
						"^_build/",
						"/_build/",
						"^htmlcov/",
						"/htmlcov/",
						"__pycache__",
					},
				},
			})
			local builtin = require("telescope.builtin")
			map("n", "<C-p>", function()
				builtin.find_files({ silent = true })
			end, {})
			map("n", "<C-b>", builtin.buffers, { silent = true })
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto",
					globalstatus = true,
				},
			})
		end,
	},

	{
		"neovim-treesitter/nvim-treesitter",
		dependencies = { "neovim-treesitter/treesitter-parser-registry" },
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			ts.install({
				"python",
				"lua",
				"vim",
				"vimdoc",
				"markdown",
				"markdown_inline",
				"bash",
				"json",
				"yaml",
				"latex",
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"python",
					"lua",
					"vim",
					"markdown",
					"bash",
					"json",
					"yaml",
					"latex",
				},
				callback = function()
					vim.treesitter.start()
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local autocmd = vim.api.nvim_create_autocmd
			local map = vim.keymap.set

			vim.lsp.config("ruff", {
				init_options = {
					settings = {
						organizeImports = true,
					},
				},
				on_attach = function(client, _)
					-- Let `basedpyright` own hover/docs.
					client.server_capabilities.hoverProvider = false
				end,
			})

			vim.lsp.config("basedpyright", {
				capabilities = capabilities,
				settings = {
					basedpyright = {
						analysis = {
							typeCheckingMode = "off",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "openFilesOnly",
						},
					},
				},
				on_new_config = function(config, _)
					config.settings = config.settings or {}
					config.settings.python = config.settings.python or {}
					config.settings.python.pythonPath = vim.fn.exepath("python")
				end,
			})

			vim.lsp.enable("ruff")
			vim.lsp.enable("basedpyright")

			autocmd("LspAttach", {
				callback = function(args)
					local opts = { buffer = args.buf }
					map("n", "gd", vim.lsp.buf.definition, opts)
					map("n", "gr", vim.lsp.buf.references, opts)
					map("n", "K", vim.lsp.buf.hover, opts)
					map("n", "<leader>rn", vim.lsp.buf.rename, opts)
					map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					map("n", "<leader>e", vim.diagnostic.open_float, opts)
					map("n", "[d", vim.diagnostic.goto_prev, opts)
					map("n", "]d", vim.diagnostic.goto_next, opts)
				end,
			})

			autocmd("BufWritePre", {
				pattern = "*.py",
				callback = function()
					vim.lsp.buf.code_action({
						apply = true,
						context = {
							only = { "source.organizeImports.ruff" },
							diagnostics = {},
						},
					})
				end,
			})
		end,
	},

	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					python = { "ruff_format" },
					lua = { "stylua" },
				},
				format_on_save = {
					timeout_ms = 1000,
					lsp_format = "fallback",
				},
			})
		end,
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "buffer" },
				}),
			})
		end,
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		opts = {},
		config = function()
			require("render-markdown").setup({
				code = {
					conceal_delimiters = false,
					language = false,
					border = "none",
				},
			})
		end,
	},

	{
		"lervag/vimtex",
		ft = { "tex" },
		init = function()
			vim.g.vimtex_view_method = "skim"
			vim.g.vimtex_view_skim_sync = 1
			vim.g.vimtex_view_skim_activate = 1
			vim.g.vimtex_compiler_latexmk = {
				build_dir = "",
				callback = 1,
				continuous = 0,
				executable = "latexmk",
				hooks = {},
				options = {
					"-shell-escape",
					"-verbose",
					"-file-line-error",
					"-synctex=1",
					"-interaction=nonstopmode",
				},
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "tex",
				callback = function(args)
					map("n", "<leader>b", ":w<CR>:VimtexCompile<CR>", {
						buffer = args.buf,
						silent = true,
					})
				end,
			})
		end,
	},
})

vim.cmd.colorscheme("solarized")

-- Insert a reference.
function _G.InsertReference(output)
	local first = vim.split(output, " | ")[1] or output
	vim.api.nvim_put({ first }, "c", true, true)
	vim.cmd("startinsert!")
end

-- Organise TODOs.
function _G.OrganiseTODOs()
	vim.cmd("update")
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		vim.notify("Buffer has no file path.", vim.log.levels.ERROR)
		return
	end

	local command = "python " .. todo_py_path .. " " .. vim.fn.shellescape(filepath)
	local output = vim.fn.system(command)

	if vim.v.shell_error == 0 then
		local view = vim.fn.winsaveview()
		vim.cmd("silent! %delete _")
		vim.fn.setline(1, vim.split(output, "\n", { plain = true }))
		vim.fn.winrestview(view)
		vim.cmd("redraw")
		vim.cmd("update")
		vim.notify("TODOs organised.")
	else
		vim.cmd("redraw")
		vim.notify(output, vim.log.levels.ERROR)
	end
end

map("n", "<leader>t", _G.OrganiseTODOs, { silent = true })

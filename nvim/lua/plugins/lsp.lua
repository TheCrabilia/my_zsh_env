return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			{
				"folke/neodev.nvim",
				event = { "BufEnter *.lua" },
				opts = {},
			},
		},
	},
	{
		"williamboman/mason.nvim",
		build = function()
			vim.cmd.MasonUpdate()
		end,
		cmd = "Mason",
		opts = {},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = { "mason.nvim" },
		opts = {
			ensure_installed = {
				-- Language servers
				"actionlint",
				"bash-language-server",
				"gopls",
				"html-lsp",
				"jdtls",
				"json-lsp",
				"lua-language-server",
				"marksman",
				"nginx-language-server",
				"pyright",
				"ruff-lsp",
				"terraform-ls",
				"vim-language-server",

				-- Formatters
				"beautysh",
				"black",
				"stylua",
				"fixjson",

				-- Linters
				"commitlint",
				"ruff",
				"tflint",
			},
			auto_update = true,
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "mason.nvim", "nvim-lspconfig" },
		config = function()
			local lspconfig = require("lspconfig")
			require("mason-lspconfig").setup_handlers({
				-- Default handler
				function(server_name)
					lspconfig[server_name].setup({
						on_attach = require("utils.lsp").on_attach,
						handlers = require("utils.lsp").handlers(),
						flags = {
							debounce_text_changes = 150,
						},
					})
				end,
				["lua_ls"] = function()
					lspconfig.lua_ls.setup({
						on_attach = require("utils.lsp").on_attach,
						handlers = require("utils.lsp").handlers(),
						flags = {
							debounce_text_changes = 150,
						},
						settings = {
							Lua = {
								runtime = { version = "LuaJIT" },
								diagnostics = {
									globals = { "vim" },
								},
								workspace = {
									library = vim.api.nvim_get_runtime_file("", true),
									maxPreload = 2000,
									preloadFileSize = 50000,
									checkThirdParty = false,
								},
								telemetry = {
									enable = false,
								},
							},
						},
					})
				end,
				["ruff_lsp"] = function()
					lspconfig.ruff_lsp.setup({
						on_attach = require("utils.lsp").on_attach,
						handlers = require("utils.lsp").handlers(),
						flags = {
							debounce_text_changes = 150,
						},
						init_options = {
							settings = {
								args = { "--config=$HOME/.config/nvim/configs/pyproject.toml" },
							},
						},
					})
				end,
				["pyright"] = function()
					lspconfig.pyright.setup({
						on_attach = function(client)
							client.server_capabilities.codeActionProvider = false
						end,
						handlers = vim.tbl_extend(
							"force",
							require("utils.lsp").handlers(),
							{ ["textDocument/publishDiagnostics"] = function() end }
						),
						flags = {
							debounce_text_changes = 150,
						},
						settings = {
							pyright = {
								alalysis = {
									autoSearchPaths = true,
									typeCheckingMode = "basic",
									useLibraryCodeForTypes = true,
								},
							},
						},
					})
				end,
				["gopls"] = function()
					lspconfig.gopls.setup({
						on_attach = function(client, bufnr)
							client.server_capabilities.semanticTokensProvider = {
								full = true,
								legend = {
									tokenTypes = {
										"namespace",
										"type",
										"class",
										"enum",
										"interface",
										"struct",
										"typeParameter",
										"parameter",
										"variable",
										"property",
										"enumMember",
										"event",
										"function",
										"method",
										"macro",
										"keyword",
										"modifier",
										"comment",
										"string",
										"number",
										"regexp",
										"operator",
										"decorator",
									},
									tokenModifiers = {
										"declaration",
										"definition",
										"readonly",
										"static",
										"deprecated",
										"abstract",
										"async",
										"modification",
										"documentation",
										"defaultLibrary",
									},
								},
							}
							require("utils.lsp").on_attach(_, bufnr)
						end,
						settings = {
							gopls = {
								semanticTokens = true,
							},
						},
					})
				end,
				["yamlls"] = function()
					lspconfig.yamlls.setup({
						on_attach = require("utils.lsp").on_attach,
						settings = {
							yaml = {
								schemaStore = {
									enable = true,
									url = "https://www.schemastore.org/api/json/catalog.json",
								},
							},
						},
					})
				end,
				["jsonls"] = function()
					lspconfig.jsonls.setup({
						on_attach = require("utils.lsp").on_attach,
						settings = {
							json = {
								schemas = require("schemastore").json.schemas(),
								validate = {
									enable = true,
								},
							},
						},
					})
				end,
				-- Disable jdtls LSP server
				["jdtls"] = function() end,
			})
		end,
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-lspconfig",
			"nvim-lua/plenary.nvim",
		},
		opts = function()
			local formatting = require("null-ls").builtins.formatting
			local diagnostics = require("null-ls").builtins.diagnostics
			return {
				sources = {
					formatting.black.with({
						extra_args = { "-l", "120" },
					}),
					formatting.ruff.with({
						extra_args = { "--config=$HOME/.config/nvim/configs/pyproject.toml" },
					}),
					formatting.stylua,
					formatting.gofmt,
					formatting.goimports,
					formatting.beautysh,
					formatting.fixjson,
					formatting.terraform_fmt,
					formatting.prettierd,
					diagnostics.zsh,
				},
			}
		end,
	},
}

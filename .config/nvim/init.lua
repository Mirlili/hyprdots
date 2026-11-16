-- ========================================================================== --
--                        1. БАЗОВЫЕ НАСТРОЙКИ (OPTIONS)                      --
-- ========================================================================== --

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Нумерация строк
opt.number = true
opt.relativenumber = true

-- Подсветка текущей строки
opt.cursorline = true

-- Показывать строку состояния
opt.laststatus = 3

-- Табуляция и отступы
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Поиск
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Внешний вид
opt.termguicolors = true
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
opt.updatetime = 50

-- Системный буфер обмена
opt.clipboard = "unnamedplus"

-- Отключаем вывод устаревших предупреждений в окно
vim.g.deprecation_warnings = false

-- ========================================================================== --
--                            2. КЛАВИАТУРНЫЕ СОКРАЩЕНИЯ                      --
-- ========================================================================== --

local map = vim.keymap.set

-- [Shift + Y]: Копирование ВСЕГО файла в системный буфер обмена
map("n", "Y", function()
    local cur_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("%y+")
    vim.api.nvim_win_set_cursor(0, cur_pos)
    vim.notify("Весь файл скопирован в системный буфер!", vim.log.levels.INFO, { title = "Буфер обмена" })
end, { desc = "Скопировать весь файл в системный буфер" })

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Сохранить файл" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Выйти" })
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Открыть/закрыть Neo-tree" })
local run_win

local function format_and_run()
    if vim.bo.filetype ~= "go" then
        vim.notify("Это не Go-файл", vim.log.levels.WARN)
        return
    end

    -- форматирование через gopls (он у тебя уже стоит) и сохранение
    vim.lsp.buf.format({ async = false })
    vim.cmd("write")

    -- закрываем сплит от прошлого запуска, чтобы они не копились
    if run_win and vim.api.nvim_win_is_valid(run_win) then
        vim.api.nvim_win_close(run_win, true)
    end

    local file = vim.fn.shellescape(vim.fn.expand("%"))
    vim.cmd("botright 12split")
    vim.cmd("terminal go run " .. file)
    run_win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd p") -- вернуть курсор обратно в код
end

map("n", "<C-CR>", format_and_run, { desc = "Форматировать и запустить Go" })
map("n", "<leader>r", format_and_run, { desc = "Форматировать и запустить Go" })
-- ========================================================================== --
--                      3. УСТАНОВКА LAZY.NVIM (BOOTSTRAP)                     --
-- ========================================================================== --

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
opt.rtp:prepend(lazypath)

-- ========================================================================== --
--                            4. СПИСОК ПЛАГИНОВ                              --
-- ========================================================================== --

require("lazy").setup({
    -- 1. Цветовая схема Tokyonight
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "moon",
                transparent = false,
                styles = {
                    sidebars = "dark",
                    floats = "dark",
                },
            })
            vim.cmd("colorscheme tokyonight-moon")
        end,
    },

    -- 2. Иконки
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- 3. Библиотека UI компонентов
    { "MunifTanjim/nui.nvim", lazy = true },

    -- 4. Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        opts = {
            options = {
                theme = "tokyonight",
                globalstatus = true,
                component_separators = { left = "|", right = "|" },
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },

    -- 5. Noice.nvim
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                lsp_doc_border = true,
            },
        },
    },

    -- 6. Neo-tree
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            close_if_last_window = true,
            filesystem = {
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
                follow_current_file = { enabled = true },
            },
        },
    },

    -- 7. Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        config = function()
            local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
            if not ok then return end
            ts_configs.setup({
                ensure_installed = {
                    "bash", "python", "rust", "yaml", "go", "sql",
                    "lua", "vim", "vimdoc", "json", "markdown"
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- 8. Автозакрытие скобок
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        dependencies = { "hrsh7th/nvim-cmp" },
        config = function()
            require("nvim-autopairs").setup({ check_ts = true })
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    -- 9. Mason (установщик LSP-серверов)
    {
        "williamboman/mason.nvim",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            local servers = {
                "bashls", "pyright", "rust_analyzer",
                "yamlls", "gopls", "sqlls", "lua_ls",
            }

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = servers,
                automatic_installation = true,
            })
        end,
    },

    -- 10. nvim-lspconfig + новый API (nvim 0.11+)
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local on_attach = function(_, bufnr)
                local bmap = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end
                bmap("n", "gd",          vim.lsp.buf.definition,  "Перейти к определению")
                bmap("n", "K",           vim.lsp.buf.hover,        "Документация под курсором")
                bmap("n", "<leader>rn",  vim.lsp.buf.rename,       "Переименовать")
                bmap("n", "<leader>ca",  vim.lsp.buf.code_action,  "Действия с кодом")
                bmap("n", "[d",          vim.diagnostic.goto_prev, "Предыдущая ошибка")
                bmap("n", "]d",          vim.diagnostic.goto_next, "Следующая ошибка")
            end

            -- Общие настройки для всех серверов (новый API nvim 0.11+)
            vim.lsp.config("*", {
                capabilities = capabilities,
                on_attach = on_attach,
            })

            -- Специфичные настройки для lua_ls (чтобы не ругался на 'vim')
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                    },
                },
            })

            -- Включаем все серверы
            vim.lsp.enable({
                "bashls", "pyright", "rust_analyzer",
                "yamlls", "gopls", "sqlls", "lua_ls",
            })
        end,
    },

    -- 11. Автодополнение (nvim-cmp)
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        event = "InsertEnter",
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                }, {
                    { name = "buffer" },
                }),
            })
        end,
    },
}, {
    git = {
        timeout = 300,
    },
})

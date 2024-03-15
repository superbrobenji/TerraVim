local lsp = require("lsp-zero").preset({})
-- local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
-- -- format on save
-- local lsp_format_on_save = function(bufnr)
--   vim.api.nvim_clear_autocmds({group = augroup, buffer = bufnr})
--   vim.api.nvim_create_autocmd('BufWritePre', {
--     group = augroup,
--     buffer = bufnr,
--     callback = function()
--       vim.lsp.buf.format()
--     end,
--   })
-- end
lsp.preset("recommended")

lsp.ensure_installed({
    'tsserver',
    -- add csharp_ls if you are going to dev with csharp, remember to install dotnet-sdk first
    -- 'csharp_ls',
    'eslint',
    'jsonls',
    'lua_ls',
    'grammarly',
    -- add gopls if you are going to dev with go, remember to install go first
    --'gopls',
    'rust_analyzer',
    'graphql',
})

lsp.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<Tab>'] = cmp.mapping(function(fallback)
        if require("copilot.suggestion").is_visible() then
            cmp.mapping.abort()
            require("copilot.suggestion").accept()
        else
            fallback()
        end
    end)
})

lsp.set_preferences({
    sign_icons = {}
})

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})
lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }
--     lsp_format_on_save(bufnr)
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.lsp.buf.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)


lsp.setup()

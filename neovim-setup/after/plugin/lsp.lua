local lsp = require("lsp-zero").preset({})
lsp.preset("recommended")

-- language servers
local ensure_installed = {
    'tsserver',
    'bashls',
    'eslint',
    'jsonls',
    'lua_ls',
    'grammarly',
    'rust_analyzer',
    'graphql',
}

-- autocompletion
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = {
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete()
}
local cmp_sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'copilot', group_index = 2 },
}
local cmp_formatting = lsp.cmp_format({
    mode = "symbol",
    max_width = 50,
    symbol_map = { Copilot = "" }
})

lsp.set_preferences({
    sign_icons = {}
})

cmp.setup({
    sources = cmp_sources,
    mapping = cmp_mappings,
    formatting = cmp_formatting
})

-- language server handlers
local lua_ls = function()
    require('lspconfig').lua_ls.setup({
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' }
                }
            }
        }
    })
end


lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }
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

require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = ensure_installed,
    handlers = {
        lsp.defaultSetup,
        lua_ls = lua_ls,
    }
})


lsp.setup()

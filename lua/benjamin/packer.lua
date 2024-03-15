-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.2',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    --     use({
    --         'rose-pine/neovim',
    --         as = 'rose-pine',
    --         config = function()
    --             vim.cmd('colorscheme rose-pine')
    --         end
    --     })
    use({
        'folke/tokyonight.nvim',
        as = 'tokyonight',
        config = function()
            vim.cmd('colorscheme tokyonight')
        end
    })
    use("lukas-reineke/indent-blankline.nvim")
    use("HiPhish/rainbow-delimiters.nvim")
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('nvim-treesitter/playground')
    use('ThePrimeagen/harpoon')
    use('mbbill/undotree')
    use('tpope/vim-fugitive')
    use('neovim/nvim-lspconfig')
    use("voldikss/vim-floaterm")
    use { 'prettier/vim-prettier',
        run = 'yarn install',
        ft = { 'javascript', 'typescript', 'css', 'less', 'scss', 'graphql', 'markdown', 'vue', 'html' }
    }
    use { 'rest-nvim/rest.nvim', requires = { 'nvim-lua/plenary.nvim' } }
    use("zbirenbaum/copilot.lua")
    use('mattkubej/jest.nvim')
    use('nvim-tree/nvim-web-devicons')
    use({ 'nvim-tree/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons' })
    use('mfussenegger/nvim-dap')
    use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
    use('folke/neodev.nvim')
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            { 'neovim/nvim-lspconfig' },             -- Required
            { 'williamboman/mason.nvim' },           -- Optional
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },
        }
    }
end)

# Welcome to TerraVim

TerraVim is a Neovim dotfile setup created to get you up and running as quickly as possible with kitty terminal and tmux

# NB!! IT IS NOT IN WORKING CONDITION YET AND IN PROGRESS

## Installation Steps
- run sh -c "$(curl -fsSL https://raw.githubusercontent.com/superbrobenji/TerraVim/main/install.sh)"
- Run `:Copilot auth` and follow the prompts if you want copilot enabled.

## LSP and Parser settings
- `:Mason` opens the LSP package manager where you can find and install any LSP config or linter you want.
- `:LspInstall` finds and installs any relevant Lsp packages or linters for you file you're on.
- `:TSUpdate` will update Treesitter.
- To update the list of LSPs you want to ensure are installed. Update the `ensure_installed` object in `nvim/after/plugin/toolinstaller.lua`. There are some core tools in `nvim/after/plugin/lsp.lua` that you can edit as well.
- To update the list of Treesitter parser languages you want to ensure are installed. Update the `ensure_installed` object in `nvim/after/plugin/treesitter.lua`

## Adding a nvim plugin
- To add a neovim plugin, simply add the plugin to `plugins.lua` in `lua/terravim` and restart neovim.
- Then add a new file to `after/plugin` with the plugin name and add all the config for the plugin here. Then run `:so`.

## Changing configs
All keymaps are in `lua/terravim/remap.lua` with the exception of some plugin specific remaps. 
There are some keymaps that exists in the plugin file for the plugin.

All the config settings for vim exists in `lua/terravim/set.lua`.

All the configs for the Kitty terminal exists in `~/.config/kitty`.

The config for tmux is in a file called `.tmux.config` in your home directory.
The tmux config settings for the terminal theme exists in `.tmux.tokyonight.conf`

## TODOs
- Add keybinds to readme

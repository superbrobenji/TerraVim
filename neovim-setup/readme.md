# Welcome to my neovim setup.

This setup is based on the setup from [The PrimeAgen](https://www.youtube.com/watch?v=w7i4amO_zaE)

## Installation

### Prerequisites
- You need [neovim](https://neovim.io/) installed.
- You need Grep and ripgrep installed.
- You need Node installed
#### Optional dependencies
- If you want to use Copilot, you'll need a Copilot subscription.

### Installation steps
- Clone this repo inside your config path, you can find the path by opening Neovim and type `:h rtp`.
- Run `:Copilot auth` and follow the prompts.

### Installing Kitty terminal
#### Installing Kitty
- Run `curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin`
- OR you can install it manually from [Kitty](https://github.com/kovidgoyal/kitty/releases)
#### Desktop Integration on Linux
- Run `ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/`
- Run `cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/`
- Run `cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/`
- Run `sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop`
- Run `sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop`
#### Installing Fira Code fonts
- For linux, run `sudo apt install fonts-firacode`
- For macos:
  - Run `brew tap homebrew/cask-fonts`
  - Run `brew install --cask font-fira-code`
#### Installing Oh My Zsh
- TODO
#### Config files
- Copy the files from kitty-config into the kitty folder in your config path.

### Installing tmux and fzf
#### Installing tmux
- Run `sudo apt-get install tmux` for ubuntu or `brew install tmux` for mac users.
- copy the contents of `tmux-setup` into your home directory.
#### Installing fzf
- Clone `git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf`.
- Run `~/.fzf/install`.

## Available commands
- `:Mason` This opens the LSP package manager where you can find and install any LSP config or linter you want.
- `:LspInstall` finds and installs any relevant Lsp packages or linters for you file you're on.
- `:TSUpdate` will update Treesitter.

## Things to note
- Don't forget to run tmux before opening nvim if you want to be able to jump between projects quickly and easily.
- The general keymaps are under `/lua/terravim/remap.lua`. Feel free to change them to your preference.
- The keymaps for each plugin are under their respective config file in `/after/plugin`.
- The general settings for Neovim is under `/lua/terravim/set.lua`
- If you are using Windows. Go to the `set.lua` file and change the undodir according to the comment.
- If the icons on the nvim-tree isn't working properly you need to download a [NerdFont](https://www.nerdfonts.com/font-downloads)

## Adding new packages
When you want to add a new package, add it to `/lua/terravim/plugins.lua` as the others are. Then create a new config file for in under `/after/plugin` as a `.lua` file.

## TODOs
- Create a bash script file that does all the setup for you.
- Fix formatting on save and `<leader>f` formatting for TS and JS projects using prettier files.
- Add run commands for anything that needs an npm package or external dependency to packer file.
- Add Node debugger for chrome and node in dap.
- Test csharp dap debugger.
- Test nvim setup on windows and document installation steps.
- Fresh install tests on linux and mac and update installation steps accordingly.
- Fix grammarly plugin on linux.
- Fix marksman plugin on linux.
- Possinbly write plugin to integrate nuget gallery to nvim.
- name it TerraVim? maybe make it a vim distro?

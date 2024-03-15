#!/bin/sh

set -e

# Make sure important variables exist if not already defined
#
# $USER is defined by login(1) which is not always executed (e.g. containers)
# POSIX: https://pubs.opengroup.org/onlinepubs/009695299/utilities/id.html
USER=${USER:-$(id -u -n)}
# $HOME is defined at the time of login, but it could be unset. If it is unset,
# a tilde by itself (~) will not be expanded to the current user's home directory.
# POSIX: https://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap08.html#tag_08_03
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~$USER)}"

# Default settings
REPO=${REPO:-superbrobenji/TerraVim}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

# other options
WITHKITTY=${WITHKITTY:-yes}
WITHFIRA=${WITHFIRA:-yes}
WITHZSH=${WITHZSH:-yes}
WITHOHMYZSH=${WITHOHMYZSH:-yes}
REPLACEKITTYCONFIG=${REPLACEKITTYCONFIG:-yes}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

user_can_sudo() {
  # Check if sudo is installed
  command_exists sudo || return 1
  # Termux can't run sudo, so we can detect it and exit the function early.
  case "$PREFIX" in
  *com.termux*) return 1 ;;
  esac
  # The following command has 3 parts:
  #
  # 1. Run `sudo` with `-v`. Does the following:
  #    • with privilege: asks for a password immediately.
  #    • without privilege: exits with error code 1 and prints the message:
  #      Sorry, user <username> may not run sudo on <hostname>
  #
  # 2. Pass `-n` to `sudo` to tell it to not ask for a password. If the
  #    password is not required, the command will finish with exit code 0.
  #    If one is required, sudo will exit with error code 1 and print the
  #    message:
  #    sudo: a password is required
  #
  # 3. Check for the words "may not run sudo" in the output to really tell
  #    whether the user has privileges or not. For that we have to make sure
  #    to run `sudo` in the default locale (with `LANG=`) so that the message
  #    stays consistent regardless of the user's locale.
  #
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

# The [ -t 1 ] check only works when the function is not called from
# a subshell (like in `$(...)` or `(...)`, so this hack redefines the
# function at the top level to always return false when stdout is not
# a tty.
if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi


# This function uses the logic from supports-hyperlinks[1][2], which is
# made by Kat Marchán (@zkat) and licensed under the Apache License 2.0.
# [1] https://github.com/zkat/supports-hyperlinks
# [2] https://crates.io/crates/supports-hyperlinks
#
# Copyright (c) 2021 Kat Marchán
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
supports_hyperlinks() {
  # $FORCE_HYPERLINK must be set and be non-zero (this acts as a logic bypass)
  if [ -n "$FORCE_HYPERLINK" ]; then
    [ "$FORCE_HYPERLINK" != 0 ]
    return $?
  fi

  # If stdout is not a tty, it doesn't support hyperlinks
  is_tty || return 1

  # DomTerm terminal emulator (domterm.org)
  if [ -n "$DOMTERM" ]; then
    return 0
  fi

  # VTE-based terminals above v0.50 (Gnome Terminal, Guake, ROXTerm, etc)
  if [ -n "$VTE_VERSION" ]; then
    [ $VTE_VERSION -ge 5000 ]
    return $?
  fi

  # If $TERM_PROGRAM is set, these terminals support hyperlinks
  case "$TERM_PROGRAM" in
  Hyper|iTerm.app|terminology|WezTerm|vscode) return 0 ;;
  esac

  # These termcap entries support hyperlinks
  case "$TERM" in
  xterm-kitty|alacritty|alacritty-direct) return 0 ;;
  esac

  # xfce4-terminal supports hyperlinks
  if [ "$COLORTERM" = "xfce4-terminal" ]; then
    return 0
  fi

  # Windows Terminal also supports hyperlinks
  if [ -n "$WT_SESSION" ]; then
    return 0
  fi

  # Konsole supports hyperlinks, but it's an opt-in setting that can't be detected
  # https://github.com/ohmyzsh/ohmyzsh/issues/10964
  # if [ -n "$KONSOLE_VERSION" ]; then
  #   return 0
  # fi

  return 1
}

# Adapted from code and information by Anton Kochkov (@XVilka)
# Source: https://gist.github.com/XVilka/8346728
supports_truecolor() {
  case "$COLORTERM" in
  truecolor|24bit) return 0 ;;
  esac

  case "$TERM" in
  iterm           |\
  tmux-truecolor  |\
  linux-truecolor |\
  xterm-truecolor |\
  screen-truecolor) return 0 ;;
  esac

  return 1
}

fmt_link() {
  # $1: text, $2: url, $3: fallback mode
  if supports_hyperlinks; then
    printf '\033]8;;%s\033\\%s\033]8;;\033\\\n' "$2" "$1"
    return
  fi

  case "$3" in
  --text) printf '%s\n' "$1" ;;
  --url|*) fmt_underline "$2" ;;
  esac
}

fmt_underline() {
  is_tty && printf '\033[4m%s\033[24m\n' "$*" || printf '%s\n' "$*"
}

# shellcheck disable=SC2016 # backtick in single-quote
fmt_code() {
  is_tty && printf '`\033[2m%s\033[22m`\n' "$*" || printf '`%s`\n' "$*"
}

fmt_error() {
  printf '%sError: %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}

setup_color() {
  # Only use colors if connected to a terminal
  if ! is_tty; then
    FMT_RAINBOW=""
    FMT_RED=""
    FMT_GREEN=""
    FMT_YELLOW=""
    FMT_BLUE=""
    FMT_BOLD=""
    FMT_RESET=""
    return
  fi

  if supports_truecolor; then
    FMT_RAINBOW="
      $(printf '\033[38;2;255;0;0m')
      $(printf '\033[38;2;255;97;0m')
      $(printf '\033[38;2;247;255;0m')
      $(printf '\033[38;2;0;255;30m')
      $(printf '\033[38;2;77;0;255m')
      $(printf '\033[38;2;168;0;255m')
      $(printf '\033[38;2;245;0;172m')
    "
  else
    FMT_RAINBOW="
      $(printf '\033[38;5;196m')
      $(printf '\033[38;5;202m')
      $(printf '\033[38;5;226m')
      $(printf '\033[38;5;082m')
      $(printf '\033[38;5;021m')
      $(printf '\033[38;5;093m')
      $(printf '\033[38;5;163m')
    "
  fi

  FMT_RED=$(printf '\033[31m')
  FMT_GREEN=$(printf '\033[32m')
  FMT_YELLOW=$(printf '\033[33m')
  FMT_BLUE=$(printf '\033[34m')
  FMT_BOLD=$(printf '\033[1m')
  FMT_RESET=$(printf '\033[0m')
}

os='unknown'
case $(uname | tr '[:upper:]' '[:lower:]') in
      linux*)
        os='linux64'
        wget -c https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -O - | tar -xz
        ;;
      darwin*)
        os='macos'
        ;;
      msys*)
          os='win64'
        ;;
esac

# block windows until proper support is added
if [ $os = 'win64' ]
then
    echo "${FMT_RED}Windows is not supported${FMT_RESET}"
    exit 1
fi
setup_grep() {
    if  command_exists ggrep  ||  command_exists rg  || command_exists grep 
    then
        echo "${FMT_BLUE}Installing Grep...${FMT_RESET}"
        wget http://ftp.gnu.org/gnu/grep/grep-3.1.tar.xz
        tar -xvf grep-3.1.tar.xz
        cd grep-3.1
        ./configure
        make
        
        if user_can_sudo; then
            sudo -k make install
        else
            make install
        fi
    else
        echo "${FMT_GREEN}Grep is already installed${FMT_RESET}"
    fi
}

# if 1, apt-get, if 2, brew, if 0, unknown
check_package_manager() {
    if command_exists apt-get
    then
        return 1
    elif command_exists brew
    then
        return 2
    else
        return 0
    fi
}

# find way to isntall without package manager
setup_ripgrep() {
    if ! command_exists rg
    then
        echo "${FMT_BLUE}Installing ripgrep...${FMT_RESET}"
        if  check_package_manager 1
        then
            if user_can_sudo; then
                sudo -k apt-get install -y ripgrep
            else
                apt-get install -y ripgrep
            fi
        elif check_package_manager 2
        then
            brew install ripgrep
        fi
    else
        echo "${FMT_GREEN}ripgrep is already installed${FMT_RESET}"
    fi
}

setup_fzf() {
    if ! command_exists fzf
    then
        echo "${FMT_BLUE}Installing fzf...${FMT_RESET}"
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        "$HOME/.fzf/install"
    else
        echo "${FMT_GREEN}fzf is already installed${FMT_RESET}"
    fi
}

# find way to isntall without package manager
setup_tmux() {
    if ! command_exists tmux
    then
        echo "${FMT_BLUE}Installing tmux...${FMT_RESET}"
        if  check_package_manager 1
        then
            if user_can_sudo; then
                sudo -k apt-get install -y tmux
            else
                apt-get install -y tmux
            fi
        elif check_package_manager 2
        then
            brew install ripgrep
        fi
    else
        echo "${FMT_GREEN}tmux is already installed${FMT_RESET}"
    fi
    if [ -f ~/.tmux.conf ]
    then
        cp tmux-setup/tmux.conf.tokyonight "$HOME/"
        if ! [ -d "$HOME/.local/scripts" ]
        then
            mkdir -p "$HOME/.local/scripts"
        fi
        cp tmux-setup/.local/scripts/* "$HOME/.local/scripts/"
        echo "source-file ./.tmux.tokyonight.conf" >> "$HOME/.tmux.conf"
    else 
        cp tmux-setup/* "$HOME/"
    fi
}

# find way to isntall without package manager
setup_zsh() {
    if ! command_exists zsh
    then
        echo "${FMT_BLUE}Installing zsh...${FMT_RESET}"
        if  check_package_manager 1
        then
            if user_can_sudo; then
                sudo -k apt-get install -y zsh
            else
                apt-get install -y zsh
            fi
        elif check_package_manager 2
        then
            brew install zsh
        fi
    else
        echo "${FMT_GREEN}zsh is already installed${FMT_RESET}"
    fi
}

setup_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ] 
    then
        echo "${FMT_BLUE}Installing oh-my-zsh...${FMT_RESET}"
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)""" --unattended
        chsh -s $(which zsh)
    else
        echo "${FMT_GREEN}oh-my-zsh is already installed${FMT_RESET}"
    fi
}

setup_neovim() {
    if ! command_exists nvim
    then
        echo "${FMT_BLUE}Installing neovim...${FMT_RESET}"
        nvimlink="https://github.com/neovim/neovim/releases/latest/download/nvim-${os}.tar.gz"
        wget -c $nvimlink -O - | tar -xz
    else
        echo "${FMT_GREEN}neovim is already installed${FMT_RESET}"
    fi
}

setup_kitty() {
    if ! [ $TERM = "xterm-kitty" ]
    then
        echo "${FMT_BLUE}Installing kitty...${FMT_RESET}"
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
        if [ $os = 'linux64' ]
        then
            ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/"
            cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/"
            cp "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/"
            sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$HOME/.local/share/applications/kitty*.desktop"
            sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" "$HOME/.local/share/applications/kitty*.desktop"
        fi
        cp kitty-config/* "$HOME/.config/kitty/"
        if [ $REPLACEKITTYCONFIG = 'yes' ]
        then
            cp kitty-config/* "$HOME/.config/kitty/"
        else 
            if [ -f ~/.config/kitty/kitty.conf ]
            then
                cp kitty-config/tokyonight_storm.conf "$HOME/.config/kitty/"
                echo "include tokyonight_storm.conf" >> "$HOME/.config/kitty/kitty.conf"
            else
                cp kitty-config/* "$HOME/.config/kitty/"
            fi
        fi

    else
        echo "${FMT_GREEN}kitty is already installed${FMT_RESET}"
    fi
}

setup_fira_code() {
    if [ $WITHFIRA = 'yes' ]
    then
        echo "${FMT_BLUE}Installing Fira Code...${FMT_RESET}"
        if [ $os = 'linux64' ]
        then
            sudo apt-get install -y fonts-firacode
        elif [ $os = 'macos' ]
        then
            brew tap homebrew/cask-fonts
            brew install --cask font-fira-code
        fi
    else
        echo "${FMT_GREEN}Fira Code is already installed${FMT_RESET}"
    fi
}

setup_dotfiles() {
    if ! [ -d "$HOME/.config/nvim" ]
    then
        mkdir -p "$HOME/.config/nvim"
    fi
    cp neovim-setup/* "$HOME/.config/nvim/"
    git clone --depth 1 https://github.com/wbthomason/packer.nvim\
        "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
}

# shellcheck disable=SC2183  # printf string has more %s than arguments ($FMT_RAINBOW expands to multiple arguments)
setup_success() {
  printf '%s _______ %s  %s    %s     %s   %s__      __%s_ %s       %s\n'      $FMT_RAINBOW $FMT_RESET
  printf '%s|__   __|%s  %s    %s     %s   %s\ \    / %s(_)%s       %s\n'      $FMT_RAINBOW $FMT_RESET
  printf '%s   | |%s ___ %s_ __%s _ __%s __ %s\ \  / /%s _ %s_ __ ___%s\n'  $FMT_RAINBOW $FMT_RESET
  printf "%s   | |%s/ _ \%s '__%s| '__%s/ _' %s\ \/ / %s| |%s '_ ' _ \%s\n"      $FMT_RAINBOW $FMT_RESET
  printf '%s   | |%s  __/%s |  %s| | %s| (_| |%s\  /  %s| |%s | | | | |%s\n'    $FMT_RAINBOW $FMT_RESET
  printf '%s   |_|%s\___|$s_|  %s|_|  %s\__,_|%s \/   %s|_|%s_| |_| |_|%s....is now installed!%s\n' $FMT_RAINBOW $FMT_GREEN $FMT_RESET
  printf '\n'
  printf '\n'
  printf '%s\n' $FMT_RESET
}

main() {
    while [ $# -gt 0 ]; do
        case $1 in
            --no-kitty) WITHKITTY='no' ;;
            --no-fira-code) WITHFIRA='no' ;;
            --no-zsh) WITHZSH='no' ;;
            --no-oh-my-zsh) WITHOHMYZSH='no' ;;
            --no-replace-kitty-config) REPLACEKITTYCONFIG='no' ;;
            --help) echo "Usage: $0 [--no-kitty] [--no-fira-code] [--no-zsh] [--no-oh-my-zsh] [--no-replace-kitty-config]" ;;
            *) echo "Unknown option: $1" ;;
        esac
        shift
    done

    setup_color
    setup_grep
    setup_ripgrep
    setup_fzf
    setup_tmux
    setup_zsh
    setup_oh_my_zsh
    setup_neovim
    setup_kitty
    setup_fira_code
    setup_dotfiles
    setup_success
}

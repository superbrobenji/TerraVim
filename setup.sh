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
if [ $os == 'win64' ]
then
    echo "Windows is not supported"
    exit 1
fi


# isntall neovim
if ! command -v nvim &> /dev/null
then
    echo "Installing neovim..."
    nvimlink="https://github.com/neovim/neovim/releases/latest/download/nvim-${os}.tar.gz"
    wget -c $nvimlink -O - | tar -xz
fi

# update and install package managers
echo "Updating and installing package managers..."
if [ $os == 'linux64' ]
then 
    if ! command -v apt-get &> /dev/null
    then
        echo 'apt-get not found'
        exit 1
    fi
    sudo apt-get update
elif [ $os == 'macos' ]
then
    if ! command -v brew &> /dev/null
    then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi

# install dependencies
echo "Installing dependencies..."

# install Grep and ripgrep
if ! command -v grep &> /dev/null
then
    if [ $os == 'linux64' ]
    then
        sudo apt-get install -y grep
    elif [ $os == 'macos' ]
    then
        brew install grep
    fi
fi

# install ripgrep
if ! command -v rg &> /dev/null
then
    if [ $os == 'linux64' ]
    then
        sudo apt-get install -y ripgrep
    elif [ $os == 'macos' ]
    then
        brew install ripgrep
    fi
fi

# install fzf
if ! command -v fzf &> /dev/null
then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

# install tmux
if ! command -v tmux &> /dev/null
then
    if [ $os == 'linux64' ]
    then
        sudo apt-get install -y tmux
    elif [ $os == 'macos' ]
    then
        brew install tmux
    fi
fi

# optional installs, ask for user input
# install zsh
echo "Do you want to install zsh? (Y/n)"
read -r response
if [ "$response" == "Y" ] || [ "$response" == "y" ] || [ "$response" == "" ]
then
    if [ $os == 'linux64' ]
    then
        sudo apt-get install -y zsh
    elif [ $os == 'macos' ]
    then
        brew install zsh
    fi
fi

# install oh-my-zsh
echo "Do you want to install oh-my-zsh? (Y/n)"
read -r response
if [ "$response" == "Y" ] || [ "$response" == "y" ] || [ "$response" == "" ]
then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# install kitty terminal 
echo "Do you want to install kitty terminal? (Y/n)"
read -r response
if [ "$response" == "Y" ] || [ "$response" == "y" ] || [ "$response" == "" ]
then
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    if [ $os == 'linux64' ]
    then
        ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
        cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
        cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
        sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
        sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
    fi
    cp kitty-config/* ~/.config/kitty/
fi

# install fira code font
echo "Do you want to install Fira Code font? (Y/n)"
read -r response
if [ "$response" == "Y" ] || [ "$response" == "y" ] || [ "$response" == "" ]
then
    if [ $os == 'linux64' ]
    then
        sudo apt-get install -y fonts-firacode
    elif [ $os == 'macos' ]
    then
        brew tap homebrew/cask-fonts
        brew install --cask font-fira-code
    fi
fi

# copy configuration files
echo "Copying configuration files..."

# copy tmux setup files into home directory
cp tmux-setup/* ~/

# copy neovim setup files into .config
mkdir -p ~/.config/nvim
cp neovim-setup/* ~/.config/nvim/
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

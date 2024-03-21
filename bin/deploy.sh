#!/usr/bin/env bash

set -e

USER=$(whoami)

upgrade_bash() {
    if ! bash --version | grep 'version 5' ; then
        if [[ "Darwin" == $(uname -s) ]] ; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            if ! which brew ; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
            brew install bash
        fi
    fi
}
install_git_repos() {
    echo About to install git repos
    cd $HOME
    if [ ! -f "$HOME/.mcv/.git/index" ] ; then
        git clone --depth=1 -b $BRANCH https://github.com/mgi1982/mcv.git $HOME/.mcv
    fi
    if [ ! -f "$HOME/.oh-my-zsh/.git/index" ] ; then
        echo "Installing oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
        if [ -f "$HOME/.zshrc" ] ; then
            mv .zshrc{,.bak-$(date +%Y%m%d)}
        fi
        ln -s $HOME/.mcv/configs/zshrc $HOME/.zshrc
        ln -s $HOME/.mcv/configs/p10k.zsh $HOME/.p10k.zsh
    fi

    if [ ! -f "$HOME/.vim_runtime/.git/index" ] ; then
        echo "Installing The Ultimate vimrc from https://github.com/amix/vimrc"
        git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
        sh $HOME/.vim_runtime/install_awesome_vimrc.sh
        cd $HOME/.vim_runtime/my_plugins
        git clone --depth=1 https://github.com/christoomey/vim-tmux-navigator.git
        git clone --depth=1 https://github.com/hashivim/vim-terraform.git
        git clone --depth=1 https://github.com/johngrib/vim-game-code-break.git
        git clone --depth=1 https://github.com/majutsushi/tagbar.git
        git clone --depth=1 https://github.com/ycm-core/YouCompleteMe.git
        if [[ $(uname -a | grep Kali) ]] ; then
            sudo apt install -y golang cmake
        fi
        cd YouCompleteMe
        git submodule update --init --recursive
        python3 install.py --ts-completer --go-completer
        GNAME="$USER"
        if [[ "Darwin" == $(uname -s) ]] ; then
            GNAME="staff"
        fi
        chown -R $USER:$GNAME $HOME/.vim_runtime
        cd $HOME
        if [ -f "$HOME/.vimrc" ] ; then
            mv .vimrc{,.bak-$(date +%Y%m%d)}
        fi
        ln -s $HOME/.mcv/configs/vimrc $HOME/.vimrc
    fi

    cd
    if [ ! -f "$HOME/.tmux/.git/index" ] ; then
        git clone --depth=1 https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
        ln -s ".tmux/.tmux.conf" ".tmux.conf"
        ln -s $HOME/.mcv/configs/tmux.conf.local $HOME/.tmux.conf.local
    fi
}

install_node() {
    echo Setting up nvm and the latest Node LTS
    if [ ! -d $HOME/.nvm ] ; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
        nvm install --lts
    fi
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
}

install_binaries() {
    echo Setting up binary programs
    if [[ "Darwin" == $(uname -s) ]] ; then
        declare -A BREW
        BREW[rg]=ripgrep
        BREW[watch]=watch
        BREW[mc]=mc
        BREW[htop]=htop
        BREW[axel]=axel
        BREW[/opt/homebrew/bin/vim]=vim
        BREW[wget]=wget
        BREW[bat]=bat
        BREW[ncdu]=ncdu
        BREW[cmake]=cmake
        BREW[openconnect]=openconnect
        BREW[git-crypt]=git-crypt
        BREW[glances]=glances
        BREW[gron]=gron
        BREW[gpg]=gnupg
        BREW[icdiff]=icdiff
        BREW[yt-dlp]=yt-dlp
        BREW[locate]=mlocate
        BREW[go]=go
        BREW[jq]=jq
        BREW[shellcheck]=shellcheck
        BREW[git-lfs]=git-lfs
        BREW[grpcurl]=grpcurl
        BREW[mogrify]=imagemagick
        BREW[kubectl]=kubectl
        BREW[helm]=helm
        BREW[tmux]=tmux
        BREW[gitui]=gitui
        BREW[mplayer]=mplayer
        BREW[figlet]=figlet
        BREW[yq]=yq
        BREW[pbzip2]=pbzip2
        for i in "${!BREW[@]}" ; do
            which -s "$i" 1> /dev/null || TOBREW="${TOBREW} ${BREW[$i]}"
        done
        [[ ! -z "${TOBREW}" ]] && brew install ${TOBREW}
        declare -A CASK
        CASK[iterm2]=iterm2
        CASK[insync]=insync
        CASK[itsycal]=itsycal
        CASK[brave-browser]=brave-browser
        CASK[lando]=lando
        CASK[rectangle]=rectangle
        CASK[signal]=signal
        CASK[slack]=slack
        CASK[discord]=discord
        CASK[gimp]=gimp
        CASK[basecamp]=basecamp
        CASK[clipy]=clipy
        CASK[calibre]=calibre
        CASK[spotify]=spotify
        CASK[zoom]=zoom
        CASK[alfred]=alfred
        CASK[buttercup]=buttercup
        CASK[microsoft-remote-desktop]=microsoft-remote-desktop
        CASK[obsidian]=obsidian
        CASK[responsively]=responsively
        CASK[responsively]=responsively
        CASK[utm]=utm
        for i in "${!CASK[@]}"
        do
            brew list --cask | grep "$i" 1> /dev/null || TOCASK="${TOCASK} ${CASK[$i]}"
        done
        [[ ! -z "${TOCASK}" ]] && brew install --cask ${TOCASK}
        echo
    elif [[ -f '/usr/bin/apt' ]] ; then # apt: Ubuntu or debian
        declare -A APT
        if [[ $(uname -a | grep Kali) ]] ; then
            echo "Kali linux, we skip other programs"
            APT[ansible]=ansible-core
        else
            echo "Classic debian/ubuntu"
            APT[kubectl]=kubectl
            APT[helm]=helm
            APT[firefox-developer-edition]=firefox-developer-edition
            APT[signal-desktop]=signal-desktop
            APT[slack]=slack-desktop
            APT[lando]=lando
            APT[zoom]=zoom
            APT[discord]=discord
            APT[insync]=insync
            APT[gitui]=gitui
            APT[brave]=brave-bin
            APT[spotify]=spotify
            APT[ansible]=ansible
        fi
        APT[mc]=mc
        APT[ncdu]=ncdu
        APT[xclip]=xclip
        APT[htop]=htop
        APT[axel]=axel
        APT[vim]=vim
        APT[tmux]=tmux
        APT[bat]=bat
        APT[rg]=ripgrep
        APT[git-crypt]=git-crypt
        APT[terminator]=terminator
        APT[unzip]=unzip
        APT[cmake]=cmake
        APT[git-lfs]=git-lfs
        APT[jq]=jq
        APT[route]=net-tools
        APT[host]=dnsutils
        APT[smplayer]=smplayer
        APT[shellcheck]=shellcheck
        APT[glances]=glances
        APT[calibre]=calibre
        APT[yt-dlp]=yt-dlp
        APT[gimp]=gimp
        APT[locate]=mlocate
        APT[gdb]=gdb
        APT[inotifywait]=inotify-tools
        APT[mogrify]=imagemagick
        APT[gron]=gron
        APT[mycli]=mycli
        APT[icdiff]=icdiff
        APT[figlet]=figlet
        APT[yq]=yq
        APT[ksnip]=ksnip
        APT[go]=golang
        for i in "${!APT[@]}" ; do
            which "$i" 1> /dev/null || TOAPT="${TOAPT} ${APT[$i]}"
        done
        [[ ! -z "${TOAPT}" ]] && sudo apt install -y ${TOAPT}
    else
        declare -A PACMAN
        PACMAN[mc]=mc
        PACMAN[xclip]=xclip
        PACMAN[htop]=htop
        PACMAN[axel]=axel
        PACMAN[vim]=gvim
        PACMAN[tmux]=tmux
        PACMAN[bat]=bat
        PACMAN[rg]=ripgrep
        PACMAN[ncdu]=ncdu
        PACMAN[git-crypt]=git-crypt
        PACMAN[terminator]=terminator
        PACMAN[unzip]=unzip
        PACMAN[cmake]=cmake
        PACMAN[git-lfs]=git-lfs
        PACMAN[jq]=jq
        PACMAN[route]=net-tools
        PACMAN[host]=dnsutils
        PACMAN[smplayer]=smplayer
        PACMAN[shellcheck]=shellcheck
        PACMAN[firefox-developer-edition]=firefox-developer-edition
        PACMAN[glances]=glances
        PACMAN[calibre]=calibre
        PACMAN[yt-dlp]=yt-dlp
        PACMAN[gimp]=gimp
        PACMAN[locate]=mlocate
        PACMAN[gdb]=gdb
        PACMAN[signal-desktop]=signal-desktop
        PACMAN[inotifywait]=inotify-tools
        PACMAN[kubectl]=kubectl
        PACMAN[helm]=helm
        PACMAN[mogrify]=imagemagick
        PACMAN[ansible]=ansible
        PACMAN[discord]=discord
        PACMAN[gitui]=gitui
        PACMAN[xsel]=xsel
        PACMAN[figlet]=figlet
        PACMAN[yq]=yq
        PACMAN[go]=go
        PACMAN[element-desktop]=element-desktop
        PACMAN[xfreerdp]=freerdp
        PACMAN[obsidian]=obsidian
        PACMAN[ksnip]=ksnip
        PACMAN[patch]=patch
        PACMAN[make]=make
        for i in "${!PACMAN[@]}" ; do
            which $i 1> /dev/null || TOINSTALL="${TOINSTALL} ${PACMAN[$i]}"
        done
        [[ ! -z "${TOINSTALL}" ]] && sudo pacman -Sy --noconfirm ${TOINSTALL}
        declare -A PAMAC
        PAMAC[slack]=slack-desktop
        PAMAC[brave]=brave-bin
        PAMAC[zoom]=zoom
        PAMAC[lando]=lando-bin
        PAMAC[mycli]=mycli-git
        PAMAC[spotify]=spotify
        PAMAC[insync]=insync
        PAMAC[signal-desktop-beta]=signal-desktop-beta-bin
        PAMAC[icdiff]=icdiff
        PAMAC[zoom]=zoom
        PAMAC[zeal]=zeal
        PAMAC[buttercup]=buttercup-desktop
        PAMAC[imgcat]=imgcat
        for i in "${!PAMAC[@]}"
        do
            which "$i" > /dev/null 2>&1 || TOBUILD="$TOBUILD ${PAMAC[$i]}"
        done
        [[ ! -z "${TOINSTALL}" ]] && pamac build --no-confirm ${TOBUILD}
    fi
    echo
}

bind_normal() {
    cd $HOME

    if [ -d "$PRIMARY_SYNC_FOLDER" ] ; then
        ls -1 "$PRIMARY_SYNC_FOLDER" | grep -v dotfiles | while read i
        do
            if [ ! -L "$i" ] ; then
                if [ -d "$i" ] ; then
                    sudo mv "$i" "$i.bak-$(date +%Y%m%d)"
                fi
                echo "Binding $i"
                ln -s "$PRIMARY_SYNC_FOLDER/$i"
            fi
        done
    fi
    if [ -d "$SECONDARY_SYNC_FOLDER" ] ; then
        ls -1 "$SECONDARY_SYNC_FOLDER" | grep -v dotfiles | while read i
        do
            if [ ! -L "$i" ] ; then
                if [ -d "$i" ] ; then
                    echo sudo mv "$i" "$i.bak-$(date +%Y%m%d)"
                fi
                echo "Binding $i"
                ln -s "$SECONDARY_SYNC_FOLDER/$i"
            fi
        done
    fi
}

bind_dotfiles() {
    cd $HOME
    if [ -d "$SECONDARY_SYNC_FOLDER" ] ; then
        ls -1 "$PRIMARY_SYNC_FOLDER/dotfiles" | while read i
        do
            if [ ! -L ".$i" ] ; then
                if [ -f ".$i" ] ; then
                    sudo mv ".$i" ".$i.bak-$(date +%Y%m%d)"
                fi
                if [ -d ".$i" ] ; then
                    sudo mv ".$i" ".$i.bak-$(date +%Y%m%d)"
                fi
                echo "Binding $i to .$i"
                ln -s "$PRIMARY_SYNC_FOLDER/dotfiles/$i" ".$i"
            fi
        done
    fi

    if [ -d .ssh ] ; then
        echo "Fixing .ssh permissions"
        chmod 0600 $HOME/.ssh/*
    fi

    if [ -d .gnupg ] ; then
        echo "Fixing .gnupg permissions"
        chmod 0700 .gnupg
    fi
}

BRANCH=dev

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -p|--primary)
            PRIMARY_SYNC_FOLDER="$2"
            shift
            ;;
        -s|--secondary)
            SECONDARY_SYNC_FOLDER="$2"
            shift
            ;;
        -b|--branch)
            BRANCH="$2"
            shift
            ;;
    esac

    shift # past argument or value
done

if [ ! -d "$PRIMARY_SYNC_FOLDER" ] ; then
    echo "Primary sync folder not defined, skip not binding"
fi
if [ ! -d "$SECONDARY_SYNC_FOLDER" ] ; then
    echo "Secondary sync folder not defined, skip not binding"
fi

upgrade_bash
install_node
install_git_repos
install_binaries

bind_normal
bind_dotfiles

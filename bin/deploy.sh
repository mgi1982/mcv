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

install_zsh() {
    if ! which zsh ; then
        echo Installing zsh
        if [[ -f /etc/gentoo-release ]] ; then
            sudo emerge zsh
        fi
    else
        echo Go present, skipping
    fi
}

install_rosetta() {
    if [[ "Darwin" == $(uname -s) ]] ; then
        if ! pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto 2> /dev/null; then
            echo Installing Rosetta 2
            sudo softwareupdate --install-rosetta --agree-to-license
        fi
    fi
}

install_gron() {
    if ! which gron ; then
        echo Installing gron
        if uname -a | grep aarch64 ; then
            GRON_TGZ=gron-linux-arm64-0.7.1.tgz
        else
            GRON_TGZ=gron-linux-amd64-0.7.1.tgz
        fi
        wget https://github.com/tomnomnom/gron/releases/download/v0.7.1/$GRON_TGZ
        tar xvzf $GRON_TGZ
        sudo mv gron /usr/local/bin
        rm $GRON_TGZ
    else
        echo gron present, skipping
    fi
}

install_python3() {
    if [[ "Darwin" == $(uname -s) ]] ; then
        if which python3 | grep '/usr/bin' ; then
            echo You are using built in Python, reinstalling with Homebrew
            brew install python
        fi
    fi
}

install_cmake() {
    if ! which cmake ; then
        echo Installing CMAKE
        if [[ $(uname -a | grep Kali) ]] ; then
            sudo apt install -y cmake vim-nox
        elif [[ $(uname -a | grep MANJARO) ]] ; then
            sudo pacman -Sy --noconfirm cmake make base-devel
        elif [[ -f /etc/gentoo-release ]] ; then
            sudo emerge cmake
        elif [[ "Darwin" == $(uname -s) ]] ; then
            brew install cmake
        fi
    else
        echo CMAKE present, skipping
    fi
}

install_go() {
    if ! which go ; then
        echo Installing Go
        if [[ $(uname -a | grep Kali) ]] ; then
            sudo apt install -y golang
        elif [[ $(uname -a | grep MANJARO) ]] ; then
            sudo pacman -Sy --noconfirm go
        elif [[ -f /etc/gentoo-release ]] ; then
            sudo emerge go
        elif [[ "Darwin" == $(uname -s) ]] ; then
            brew install go
        fi
    else
        echo Go present, skipping
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
        git clone --depth=1 https://github.com/posva/vim-vue.git
        git clone --depth=1 https://github.com/christoomey/vim-tmux-navigator.git
        git clone --depth=1 https://github.com/hashivim/vim-terraform.git
        git clone --depth=1 https://github.com/johngrib/vim-game-code-break.git
        git clone --depth=1 https://github.com/majutsushi/tagbar.git
        git clone --depth=1 https://github.com/ycm-core/YouCompleteMe.git
        git clone --depth=1 -b yaml https://github.com/puremourning/ycmd-1.git /tmp/ycmd-1
        cd YouCompleteMe
        git submodule update --init --recursive
        python3 install.py --ts-completer --go-completer
        mv /tmp/ycmd-1/ycmd/completers/vue $HOME/.vim_runtime/my_plugins/YouCompleteMe/third_party/ycmd/ycmd/completers/
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
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
        nvm install --lts
    fi
}

install_binaries() {
    echo Setting up binary programs
    if [[ "Darwin" == $(uname -s) ]] ; then
        declare -A BREW
        BREW[/opt/homebrew/bin/vim]=vim
        BREW[axel]=axel
        BREW[bat]=bat
        BREW[cmake]=cmake
        BREW[delta]=git-delta
        BREW[figlet]=figlet
        BREW[git-crypt]=git-crypt
        BREW[git-lfs]=git-lfs
        BREW[gitui]=gitui
        BREW[glances]=glances
        BREW[go]=go
        BREW[gpg]=gnupg
        BREW[gron]=gron
        BREW[grpcurl]=grpcurl
        BREW[helm]=helm
        BREW[htop]=htop
        BREW[icdiff]=icdiff
        BREW[jq]=jq
        BREW[kubectl]=kubectl
        BREW[locate]=mlocate
        BREW[mc]=mc
        BREW[mogrify]=imagemagick
        BREW[mplayer]=mplayer
        BREW[ncdu]=ncdu
        BREW[openconnect]=openconnect
        BREW[pbzip2]=pbzip2
        BREW[rg]=ripgrep
        BREW[shellcheck]=shellcheck
        BREW[tmux]=tmux
        BREW[watch]=watch
        BREW[wget]=wget
        BREW[yq]=yq
        BREW[yt-dlp]=yt-dlp
        for i in "${!BREW[@]}" ; do
            which -s "$i" 1> /dev/null || TOBREW="${TOBREW} ${BREW[$i]}"
        done
        [[ ! -z "${TOBREW}" ]] && brew install ${TOBREW}
        declare -A CASK
        CASK[alfred]=alfred
        CASK[basecamp]=basecamp
        CASK[brave-browser]=brave-browser
        CASK[calibre]=calibre
        CASK[chromium]=eloston-chromium
        CASK[dash]=dash
        CASK[ferdium]=ferdium
        CASK[gimp]=gimp
        CASK[insync]=insync
        CASK[iterm2]=iterm2
        CASK[itsycal]=itsycal
        CASK[keepassxc]=keepassxc
        CASK[lando]=lando
        CASK[localsend-bin]=localsend
        CASK[maccy]=maccy
        CASK[obsidian]=obsidian
        CASK[rectangle]=rectangle
        CASK[signal]=signal
        CASK[spotify]=spotify
        CASK[utm]=utm
        CASK[windows-app]=windows-app
        CASK[zed]=zed
        CASK[zoom]=zoom
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
            APT[ansible]=ansible
            APT[brave]=brave-bin
            APT[gimp]=gimp
            APT[gitui]=gitui
            APT[helm]=helm
            APT[insync]=insync
            APT[kubectl]=kubectl
            APT[signal-desktop]=signal-desktop
            APT[spotify]=spotify
            APT[zoom]=zoom
        fi
        APT[axel]=axel
        APT[bat]=bat
        APT[calibre]=calibre
        APT[delta]=git-delta
        APT[figlet]=figlet
        APT[gdb]=gdb
        APT[git-crypt]=git-crypt
        APT[git-lfs]=git-lfs
        APT[glances]=glances
        APT[host]=dnsutils
        APT[htop]=htop
        APT[icdiff]=icdiff
        APT[inotifywait]=inotify-tools
        APT[jq]=jq
        APT[locate]=mlocate
        APT[mc]=mc
        APT[mogrify]=imagemagick
        APT[mycli]=mycli
        APT[ncdu]=ncdu
        APT[rg]=ripgrep
        APT[route]=net-tools
        APT[shellcheck]=shellcheck
        APT[smplayer]=smplayer
        APT[tmux]=tmux
        APT[unzip]=unzip
        APT[vim]=vim
        APT[xclip]=xclip
        APT[yq]=yq
        APT[yt-dlp]=yt-dlp
        for i in "${!APT[@]}" ; do
            which "$i" 1> /dev/null || TOAPT="${TOAPT} ${APT[$i]}"
        done
        [[ ! -z "${TOAPT}" ]] && sudo apt install -y ${TOAPT}
    elif [[ -f '/usr/bin/emerge' ]] ; then # gentoo
        if ! eselect repository list -i | grep gentoo-zh ; then
            sudo eselect repository enable gentoo-zh
            sudo emerge --sync gentoo-zh
        fi
        if ! eselect repository list -i | grep pf4public ; then
            sudo eselect repository enable pf4public
            sudo emerge --sync pf4public
        fi
        if ! eselect repository list -i | grep guru ; then
            sudo eselect repository enable guru
            sudo emerge --sync guru
        fi
        if ! eselect repository list -i | grep haskell ; then
            sudo eselect repository enable haskell
            sudo emerge --sync haskell
        fi
        if ! eselect repository list -i | grep ppfeufer ; then
            sudo eselect repository add ppfeufer-gentoo-overlay
            sudo emerge --sync ppfeufer-gentoo-overlay
        fi
        if ! eselect repository list -i | grep brave ; then
            sudo eselect repository add brave-overlay git https://gitlab.com/jason.oliveira/brave-overlay.git
            sudo emerge --sync brave-overlay
        fi
        declare -A EMERGE
        if [[ "$HEADLESS" = false ]] ; then
            EMERGE[brave]=brave-bin
            EMERGE[chromium]=ungoogled-chromium
            EMERGE[calibre]=calibre
            EMERGE[gimp]=gimp
            EMERGE[insync]=insync
            EMERGE[localsend]=localsend-bin
            EMERGE[signal-desktop]=signal-desktop-bin
            EMERGE[smplayer]=smplayer
            EMERGE[spotify]=spotify
            EMERGE[xclip]=x11-misc/xclip
            EMERGE[xsel]=xsel
            EMERGE[zeal]=zeal
            EMERGE[zed]=zed
            EMERGE[zoom]=net-im/zoom
        else
            echo "Skipping UI programs"
        fi
        EMERGE[ansible]=ansible
        EMERGE[axel]=axel
        EMERGE[bat]=bat
        EMERGE[delta]=git-delta
        EMERGE[figlet]=figlet
        EMERGE[gdb]=gdb
        EMERGE[git-crypt]=git-crypt
        EMERGE[git-lfs]=dev-vcs/git-lfs
        EMERGE[gitui]=gitui
        EMERGE[glances]=glances
        EMERGE[helm]=app-admin/helm
        EMERGE[host]=bind-tools
        EMERGE[htop]=htop
        EMERGE[icdiff]=icdiff
        EMERGE[inotifywait]=inotify-tools
        EMERGE[jq]=app-misc/jq
        EMERGE[kubectl]=kubectl
        EMERGE[locate]=mlocate
        EMERGE[mc]=app-misc/mc
        EMERGE[mogrify]=imagemagick
        EMERGE[mycli]=mycli
        EMERGE[ncdu]=ncdu
        EMERGE[rg]=ripgrep
        EMERGE[route]=net-tools
        EMERGE[shellcheck]=shellcheck
        EMERGE[syncthing]=syncthing
        EMERGE[tmux]=tmux
        EMERGE[unzip]=unzip
        EMERGE[vim]=vim
        EMERGE[yq]=yq
        EMERGE[yt-dlp]=yt-dlp
        for i in "${!EMERGE[@]}" ; do
            which "$i" 1> /dev/null || TOEMERGE="${TOEMERGE} ${EMERGE[$i]}"
        done
        [[ ! -z "${TOEMERGE}" ]] && sudo emerge ${TOEMERGE}
    else
        declare -A PACMAN
        PACMAN[ansible]=ansible
        PACMAN[axel]=axel
        PACMAN[bat]=bat
        PACMAN[calibre]=calibre
        PACMAN[delta]=git-delta
        PACMAN[element-desktop]=element-desktop
        PACMAN[figlet]=figlet
        PACMAN[gdb]=gdb
        PACMAN[gimp]=gimp
        PACMAN[git-crypt]=git-crypt
        PACMAN[git-lfs]=git-lfs
        PACMAN[gitui]=gitui
        PACMAN[glances]=glances
        PACMAN[go]=go
        PACMAN[helm]=helm
        PACMAN[host]=dnsutils
        PACMAN[htop]=htop
        PACMAN[inotifywait]=inotify-tools
        PACMAN[jq]=jq
        PACMAN[keepassxc]=keepassxc
        PACMAN[kubectl]=kubectl
        PACMAN[locate]=mlocate
        PACMAN[make]=make
        PACMAN[mc]=mc
        PACMAN[mogrify]=imagemagick
        PACMAN[ncdu]=ncdu
        PACMAN[obsidian]=obsidian
        PACMAN[patch]=patch
        PACMAN[rg]=ripgrep
        PACMAN[route]=net-tools
        PACMAN[shellcheck]=shellcheck
        PACMAN[signal-desktop]=signal-desktop
        PACMAN[smplayer]=smplayer
        PACMAN[tmux]=tmux
        PACMAN[unzip]=unzip
        PACMAN[vim]=gvim
        PACMAN[xclip]=xclip
        PACMAN[xfreerdp3]=freerdp
        PACMAN[xsel]=xsel
        PACMAN[yq]=yq
        PACMAN[yt-dlp]=yt-dlp
        for i in "${!PACMAN[@]}" ; do
            which $i 1> /dev/null || TOINSTALL="${TOINSTALL} ${PACMAN[$i]}"
        done
        [[ ! -z "${TOINSTALL}" ]] && sudo pacman -Sy --noconfirm ${TOINSTALL}
        pamac upgrade --no-confirm --aur --force-refresh
        declare -A PAMAC
        PAMAC[brave]=brave-bin
        PAMAC[chromium]=ungoogled-chromium-bin
        PAMAC[ferdium]=ferdium
        PAMAC[icdiff]=icdiff
        PAMAC[imgcat]=imgcat
        PAMAC[insync]=insync
        PAMAC[localsend]=localsend-bin
        PAMAC[mycli]=mycli
        PAMAC[syncthing]=syncthing
        PAMAC[zeal]=zeal
        PAMAC[zed]=zed
        PAMAC[zoom]=zoom
        for i in "${!PAMAC[@]}"
        do
            which "$i" > /dev/null 2>&1 || TOBUILD="$TOBUILD ${PAMAC[$i]}"
        done
        [[ ! -z "${TOBUILD}" ]] && yes | pamac build --no-confirm ${TOBUILD}
    fi
    echo
}

install_lando() {
    if ! which lando ; then
        echo Installing Lando for web development!
        bash -c "$(curl -fsSL https://get.lando.dev/setup-lando.sh)"
    else
        echo Lando present, skipping
    fi
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
                ln -s "$PRIMARY_SYNC_FOLDER/dotfiles/$i" "$HOME/.$i"
            fi
        done
    fi

    if [ -d .ssh ] ; then
        echo "Fixing .ssh permissions"
        chmod 0600 $HOME/.ssh/*
    fi

    if [ -d .gnupg ] ; then
        echo "Fixing .gnupg permissions"
        chmod 0700 $HOME/.gnupg
    fi

    if [ -d .config/zed ] ; then
        echo "Binding ZED files"
        ls -1 "$PRIMARY_SYNC_FOLDER/zed" | while read i
        do
            if [ ! -L ".$i" ] ; then
                if [ -f ".$i" ] ; then
                    sudo mv ".$i" ".$i.bak-$(date +%Y%m%d)"
                fi
                if [ -d ".$i" ] ; then
                    sudo mv ".$i" ".$i.bak-$(date +%Y%m%d)"
                fi
                echo "Binding $i to .config/zed/$i"
                ln -s "$PRIMARY_SYNC_FOLDER/zed/$i" "$HOME/.config/zed/$i"
            fi
        done
    fi
}

BRANCH=dev
HEADLESS=false

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
        -h|--headless)
            HEADLESS=true
            ;;
    esac

    shift # past argument or value
done

if [ ! -d "$PRIMARY_SYNC_FOLDER" ] ; then
    echo "Primary sync folder not defined, skip binding"
else
    PRIMARY_SYNC_FOLDER="$(readlink -f $PRIMARY_SYNC_FOLDER)"
    echo "Using $PRIMARY_SYNC_FOLDER as primary sync folder"
fi
if [ ! -d "$SECONDARY_SYNC_FOLDER" ] ; then
    echo "Secondary sync folder not defined, skip binding"
fi

upgrade_bash
install_zsh
install_node
install_python3
install_cmake
install_go
install_git_repos
install_rosetta
install_gron
install_binaries
install_lando

bind_normal
bind_dotfiles

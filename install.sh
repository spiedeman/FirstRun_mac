#!/bin/bash

ROOTDIR=$(dirname "$(readlink -f "$0")")
export ROOTDIR
export PATH=$HOME/.local/bin:$PATH

function _install() {
    isexist=0
    echo "Available Packages:"
    for file in `ls $ROOTDIR/scripts`
    do
        echo "  ${file%.*}"
        [[ $1 == ${file%.*} ]] && isexist=1
    done
    if [ $isexist == 1 ]; then
        read -p "Package $1 is available, continue[y/n]? " goingon
        case $goingon in
            y )
                bash $ROOTDIR/scripts/$1.sh > $ROOTDIR/log/$1.log 2>&1 && echo "sucessfully installed![$1]" || exit 0
                # echo $ROOTDIR/$1.sh
                ;;
            *)
                exit
                ;;
        esac
    else
        read -p "Package '$1' is not available, continue[y/n]? " goingon
        case $goingon in
            y )
                echo "which package do you want to install? " 
                read -p ">>> " package
                _install $package
                ;;
            *)
                exit
                ;;
        esac
    fi
}

function _install_slient() {
    bash $ROOTDIR/scripts/$1.sh > $ROOTDIR/log/$1.log 2>&1 && echo "sucessfully installed![$1]" || exit 0
}

function _install_all() {
    _install_slient bash
    # _install_slient git
    _install_slient ssh
    _install_slient python
    _install_slient jupyter
    _install_slient terminal
    _install_slient vim
    _install_slient themes
    _install_slient shadowsocks
    _install_slient tmux
    _install_slient software

    # All packages are installed sucessfully
    echo "All Done. Enjoy yourself!"
}



# case ${1##*-} in
case $1 in
    -h|--help|'' ) # can be more precise with regular expression
        echo "Usage: "
        echo "  ./install.sh [options]"
        echo ""
        echo "Help Options:"
        echo "  -h, --help              Show help options"
        echo ""
        echo "Application Options:"
        echo "  -a, --all               Install all softwares and config files"
        echo "  packagename:            Install a specific package and config file"
        ;;
    -a|--all)
        _install_all
        ;;
    *)
        _install $1
        ;;
esac

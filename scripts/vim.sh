#!/bin/bash

[ -f ~/.vim/autoload/plug.vim ] || curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

[ -d ~/.vim/UltiSnips ] && rm -rf ~/.vim/UltiSnips

brew install cmake --with-completion

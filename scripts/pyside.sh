#!/bin/bash

brew tap cartr/qt4
brew tap-pin /cartr/qt4
brew install qt@4

cd $HOME/tmp
[ -d python-package ] || mkdir python-package


if ! brew list | grep wget > /dev/null; then
    brew install wget
fi

wget https://pypi.python.org/packages/source/P/PySide/PySide-1.2.4.tar.gz
[ -d pyside-1.2.4 ] && rm pyside-1.2.4
tar -zxf PySide-1.2.4.tar.gz

# git clone https://github.com/PySide/pyside-setup.git pyside-setup
cd pyside-1.2.4
python setup.py bdist_wheel --ignore-git

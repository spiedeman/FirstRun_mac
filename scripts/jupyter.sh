#!/bin/bash

function run() {

    # 创建虚拟环境 science
    mkvirtualenv science
    pip install jupyter
    pip install matplotlib
    pip install scipy sympy pandas
    pip install astropy==2.0.2 healpy
    # pip ...

    cp $ROOTDIR/config/python/postactivate $WORKON_HOME
}

lsvirtualenv | grep science > /dev/null || run

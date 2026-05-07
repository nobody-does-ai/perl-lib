#!/bin/bash

dir() { 
cd $(dirname "${BASH_SOURCE}")
cd ..
cd ..
cd ..
dir1=$(basename $PWD)
echo $dir1 >

#    if $( basename $PWD ) == "stow"; then
#      echo -Mlocal::lib=$PWD
#    fi
}

echo perl $(dir) Makefile.PL

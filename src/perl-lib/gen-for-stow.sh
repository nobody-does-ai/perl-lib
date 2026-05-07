#!/bin/bash

dir() { 
cd $(dirname "${BASH_SOURCE}")
cd ..
cd ..
cd ..
dir1=$(basename $PWD)

  if test $( basename $PWD ) == "stow"; then
   echo -Mlocal::lib=$PWD/perl-lib
  fi
}

perl $(dir) Makefile.PL

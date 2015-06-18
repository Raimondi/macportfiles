#!/usr/bin/env bash

# Update Vim's Portfile
VIMVERSION=7.4
PATCHLEVEL=$(curl https://raw.githubusercontent.com/vim/vim/master/src/version.c 2>/dev/null | sed -n '/[0-9],$/{s/,//;s/[ \t]*//;p;q;}')
VERSION=$VIMVERSION.$PATCHLEVEL
if [[ $VERSION =~ ^7\.[3-9a-zA-Z]+ ]]; then
  sed -i -e "s/^\(version  *\)[^ ]*\$/\1$VERSION/" /users/israel/ports/editors/vim/Portfile
  echo "Vim's version updated to \"$VERSION\"."
else
  echo "There was a problem getting the current Vim's version: \"$VERSION\"."
fi

# Update MacVim's Portfile
unset VIMVERSION
unset PATCHLEVEL
unset VERSION

VIMVERSION=7.4
PATCHLEVEL=$(curl https://raw.githubusercontent.com/macvim-dev/macvim/master/src/version.c 2>/dev/null | sed -n '/[0-9],$/{s/,//;s/[ \t]*//;p;q;}')
COMMITDATE=$(curl https://github.com/macvim-dev/macvim/commits/master 2>/dev/null \
  | sed -n '/Commits on/{s/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/;p;q;}' \
  | sed 's/\([0-9] \)\([1-9],\)/\10\2/' \
  | sed 's/.* \([0-9][0-9]\) \([0-3][0-9]\), \([0-9]\{4\}\)/\3\1\2/')
VERSION=$VIMVERSION.$PATCHLEVEL.$COMMITDATE
if [[ $VERSION =~ ^7\.[3-9a-zA-Z]+ ]]; then
  sed -i -e "s/^\(version  *\)[^ ]*\$/\1$VERSION/" /users/israel/ports/editors/MacVim/Portfile
  echo "MacVim's version updated to \"$VERSION\"."
else
  echo "There was a problem getting the current MacVim's version: \"$VERSION\"."
fi

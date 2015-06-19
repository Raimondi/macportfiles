#!/usr/bin/env bash

# Update Vim's Portfile
VIMVERSION=$(curl https://raw.githubusercontent.com/vim/vim/master/src/version.h 2>/dev/null | sed -n '/^#define VIM_VERSION_SHORT/{s/^#define VIM_VERSION_SHORT[[:blank:]]*"\([0-9.ab]*\)"/\1/;p;q;}')
PATCHLEVEL=$(curl https://raw.githubusercontent.com/vim/vim/master/src/version.c 2>/dev/null | sed -n '/[0-9],$/{s/,//;s/[ \t]*//;p;q;}')
VERSION=$VIMVERSION.$PATCHLEVEL
PORTFILE=/Users/israel/ports/editors/vim/Portfile
SHA=$(curl https://api.github.com/repos/vim/vim/commits/master 2>/dev/null | sed -n '/sha/{s/ *"sha": *"\([0-9a-f]*\)",/\1/;p;q;}')
if [[ $VERSION =~ ^7\.[3-9a-zA-Z]+ ]]; then
  if sed -i -e "s/^\(set vim_version  *\)[^ ]*\$/\1$VIMVERSION/" $PORTFILE; then
    echo "Vim's version updated to \"$VIMVERSION\"."
  else
    echo "Could not update Vim's version." &>2
  fi
  if sed -i -e "s/^\(set vim_patchlevel  *\)[^ ]*\$/\1$PATCHLEVEL/" $PORTFILE; then
    echo "Vim's patch level updated to \"$PATCHLEVEL\"."
  else
    echo "Could not update Vim's patch level" &>2
  fi
  if sed -i -e "/^set gitcommit/s/[0-9a-z]*\$/$SHA/" $PORTFILE; then
    echo "gitcommit updated to $SHA"
  else
    echo "Could not update gitcommit." &>2
  fi
else
  echo "There was a problem getting the Vim's current version: \"$VERSION\"." &>2
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
  echo "There was a problem getting the current MacVim's version: \"$VERSION\"." &>2
fi

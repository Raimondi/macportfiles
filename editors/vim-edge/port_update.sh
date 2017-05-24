#!/usr/bin/env bash

helper="$(dirname "$0")/../../helper.sh"
source $helper

echo "Updating Vim's Portfile..."
VIMVERSION=$(curl https://raw.githubusercontent.com/vim/vim/master/src/version.h 2>/dev/null | sed -n '/^#define VIM_VERSION_SHORT/{s/^#define VIM_VERSION_SHORT[[:blank:]]*"\([0-9.ab]*\)"/\1/;p;q;}')
echo vim version $VIMVERSION
PATCHLEVEL=$(curl https://raw.githubusercontent.com/vim/vim/master/src/version.c 2>/dev/null | sed -n '/[0-9],$/{s/,//;s/[ \t]*//;p;q;}')
echo patchlevel $PATCHLEVEL
VERSION=$VIMVERSION.$PATCHLEVEL
PORTFILE=Portfile
SHA=$(curl https://api.github.com/repos/vim/vim/commits/master 2>/dev/null | sed -n '/sha/{s/ *"sha": *"\([0-9a-f]*\)",/\1/;p;q;}')
if [[ $VERSION =~ ^[1-9]\.[0-9a-zA-Z]+ ]]; then
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

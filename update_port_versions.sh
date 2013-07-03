#!/usr/bin/env bash

# Update Vim's Portfile
VERSION=$(curl https://vim.googlecode.com/hg/.hgtags 2>/dev/null | tail -n 1 | sed -e 's/^[0-9a-f]*  *v//;s/-/./g;')
if [[ $VERSION =~ ^7\.[3-9]\.[0-9]+$ ]]; then
  sed -i -e "s/^\(version  *\)[^ ]*\$/\1$VERSION/" /users/israel/ports/editors/vim/Portfile
  echo "Vim's version updated to \"$VERSION\"."
else
  echo "There was a problem getting the current Vim's version: \"$VERSION\"."
fi

# Update MacVim's Portfile
unset VERSION
VERSION=$(curl https://raw.github.com/b4winckler/macvim/master/.hgtags 2>/dev/null | tail -n 1 | sed -e 's/^[0-9a-f]*  *v//;s/-/./g;')
if [[ $VERSION =~ ^7\.[3-9]\.[0-9]+$ ]]; then
  sed -i -e "s/^\(version  *\)[^ ]*\$/\1$VERSION/" /users/israel/ports/editors/MacVim/Portfile
  echo "MacVim's version updated to \"$VERSION\"."
else
  echo "There was a problem getting the current MacVim's version: \"$VERSION\"."
fi

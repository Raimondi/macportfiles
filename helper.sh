#!/usr/bin/env bash

function port_is_active() {
  [ "x$1" = x ] && exit 1
  port installed $1 | grep -q '(active)$'
}
function port_version() {
  [ "x$1" = x ] && exit 1
  port info $1 | sed -n -E -e 's/^[^\t ]+ @([^ ]+) \(.*/\1/;p;q'
}
function port_version_active() {
  [ "x$1" = x ] && exit 1
  port installed $1 | sed -En -e '/\(active\)$/{/^ +/s/^ +[^ ]+ +@([^ +]+)_[0-9].*\(active\)/\1/;p;q;}'
}
function logmsg() {
  [ "x$1" = x -o "y$2" = y ] && exit 99
  echo "$2"
  echo "$2" >> "$1"
}
function logerr() {
  [ "x$1" = x -o "y$2" = y ] && exit 99
  echo "err: $2" >&2
  echo "err: $2" >> "$1"
}
function port_update_init() {
  echo "Entering $(dirname "$0")"
  cd $(dirname "$0")
  cp -f Portfile port_update_Portfile.bk
}
function port_update_recover() {
  echo "Restoring Portfile"
  mv -f port_update_Portfile.bk Portfile
}
function reinplace() {
  sed_cmd="$1"
  file="$2"
  sed -i -e "$sed_cmd" "$file"
}
function port_update_github_group_info() {
  portfile="Portfile"
  grep -q '^github\.setup' "$portfile" \
    || { echo "Could not find 'github.setup' in '$portfile'"; return 3; }
  api_url="https://api.github.com/repos/$(sed -E -n -e '/^github\.setup/{s/^github\.setup[ \t]+([^\t ]+)[ \t]+([^ \t]+).*/\1\/\2/;p;q;}' "$portfile")/commits/master"
  values=($(curl "$api_url" 2>/dev/null| sed -n -E -e '/^\{$/d' -e '/^ +\},$/q;' \
    -e 's/[-:ZT]*//g;' \
    -e '/sha|date/{s/^ *"(sha|date)" +"([^ ,]+)",*/\2/;p;}' 2>/dev/null))
  newhash="${values[0]}"
  newdate="${values[1]}"
  echo "$newhash" | grep -q -E '^[0-9a-hA-H]+$' \
    || { echo "There was a problem with the hash: $newhash"; return 3; }
  [ -f "$portfile" ] \
    || { echo "'$portfile' is not a file"; return 4; }
  sed -E -i -e "/^github\\.setup/{s/(github\\.setup[\\t ]+[^ \\t]+[\\t ]+[^\\t ]+[\\t ]+)[0-9a-hA-H]+\$/\\1$newhash/;}" "$portfile"
  sed -i -e "/^version/s/[0-9]*\$/$newdate/" $portfile
}
function port_update_get_HEAD_hash() {
  url="$1"
  reference="${2-HEAD}"
  git ls-remote --exit-code "$url" "$reference"
}
function port_update_get_github_info() {
  curl https://api.github.com/repos/fish-shell/fish-shell/commits/master | sed -n -E -e '/^\{$/d' -e '/^ +\},$/q;' -e 's/[-:ZT]*//g;' -e '/sha|date/{s/^ *"(sha|date)" +"([^ ,]+)",*/\2/;p;}' 2>/dev/null
}
function port_update_get_category() {
  [ "x$1" != x ] || return 3
  port info $1 | sed -E -e '1s/[^(]+\(([a-z]+).*/\1/;q;'
}

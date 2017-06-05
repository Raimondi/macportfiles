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
  cd $(dirname "$0") || return 1
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
function fetch_gh_commit_info() {
  curl "https://api.github.com/repos/$1/$2/commits/$3" 2>/dev/null >github_commit
}
function get_gh_commit_hash() {
    sed -nE -e '/^  "sha/{s/^  "sha": +"([^ ,]+)",*/\1/;p;q;}' github_commit
}
function get_port_gh_info() {
  sed -nE -e '/^github\.setup/{s/^[\t ]*github\.setup[\t ]+//;s/ +/\
/g;p;q;}' Portfile
}
function port_update_gh_group_info() {
  portfile="Portfile"
  [ -f "$portfile" ] || { echo "'$portfile' is not a file"; return 4; }
  gh_info=($(get_port_gh_info)) \
    || { echo "Could not find 'github.setup' in '$portfile'"; return 2; }
  gh_user=${gh_info[0]}
  gh_repo=${gh_info[1]}
  fetch_gh_commit_info "$gh_user" "$gh_repo" master || return 1
  cur_hash=${gh_info[2]}
  new_hash=$(get_gh_commit_hash) || { echo "There was a problem with the hash: $new_hash"; return 3; }
  [[ "$cur_hash" = "new_hash" ]] && return 5
  newdate=$(date -u +"%Y%m%d%H%M%S")
  sed -E -i -e "/^github\\.setup/{s/(github\\.setup[\\t ]+[^ \\t]+[\\t ]+[^\\t ]+[\\t ]+)[0-9a-hA-H]+\$/\\1$new_hash/;}" "$portfile"
  sed -i -e "/^version/s/[0-9]*\$/$newdate/" $portfile
}
function port_update_get_HEAD_hash() {
  url="$1"
  reference="${2-HEAD}"
  git ls-remote --exit-code "$url" "$reference"
}
function port_update_get_category() {
  [ "x$1" != x ] || return 3
  port info $1 | sed -E -e '1s/[^(]+\(([a-z]+).*/\1/;q;'
}

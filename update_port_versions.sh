#!/usr/bin/env bash

self="$0"
while [ -h "$self" ]
do
  self=$(readlink "$self")
done

rootdir=$(cd "$(dirname "$self")" && pwd -P)
log="$rootdir/port_update.log"
portfile_bk=.port_update_Portfile.bk

cd "$rootdir"
echo '' > port_update.log
source helper.sh

portdirs=$(find * -path templates -prune -o -type d -depth 1 -print)

# Update portfiles
logmsg "$log" "Update portfiles:"
for portdir in $portdirs
do
  portname=${portdir/#*\//}
  #if ! port_is_active $portname; then
  #  echo "skipping '$portname': it is not active" >> "$log"
  #  continue
  #fi
  update_script="$rootdir/$portdir/port_update.sh"
  #logmsg "$log" "update_port: $update_script"
  if ! [ -f "$update_script" ]; then
    echo "skipping '$portname': no update script found" >> "$log"
    continue
  fi
  if ! [ -x "$update_script" ]; then
    logerr "$log" "skipping '$portname': $update_script' needs executable permission"
    continue
  fi
  if ! cd "$rootdir/$portdir"; then
    logerr "$log" "Could not cd into '$portdir'"
    continue
  fi
  logmsg "$log" "entering '$(pwd)'..."
  cp -f Portfile $portfile_bk
  logmsg "$log" "Updating $portname..."
  ($update_script 2>&1; echo >exit_code.txt $?) | tee -a "$log"
  if ! grep -q 0 exit_code.txt; then
    mv -f $portfile_bk Portfile
    logerr "$log" "could not update $portname's Portfile"
    continue
  fi
  rm -f exit_code.txt
  updated="$updated $portdir"
done
cd "$rootdir"
portindex .

# Upgrade ports
logmsg "$log" "Upgrade ports:"
for portdir in $updated
do
  portname=${portdir/#*\//}
  if port_is_active $portname && \
    [ "x$(port_version $portname)" = "x$(port_version_active $portname)" ]; then
    logmsg "$log" "skipping '$portname': it is up to date"
    continue
  fi
  if ! cd "$rootdir/$portdir"; then
    logerr "$log" "Could not cd into '$portdir'"
    continue
  fi
  if ! port installed $portname | grep -q '^None'; then
    sudo -n true 2>/dev/null || printf '\a'
    logmsg "$log" "upgrading '$portname'..."
    sudo port clean --dist $portname
    if ! sudo port upgrade --no-rev-upgrade $portname; then
      mv -f $portfile_bk Portfile
      logerr "$log" "could not upgrade $portname"
      outdated="$outdated $portname"
      continue
    fi
    upgraded="$upgraded $portname"
  fi
  rm -f $portfile_bk
done
if ! [ -z ${update+x} ]; then
  sudo -n true 2>/dev/null || printf '\a'
  sudo port rev-upgrade
fi

cd "$rootdir"
if ! [ -z ${outdated+x} ]; then
  logmsg "Could not upgrade the following outdated ports:"
  for port in $outdate
  do
    logmsg "$log" "- $port"
  done
  portindex .
fi

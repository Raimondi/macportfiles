#!/usr/bin/env bash

helper="$(dirname "$0")/../../helper.sh"
source $helper
port_update_github_group_info || exit 1

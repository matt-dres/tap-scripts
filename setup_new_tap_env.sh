#!/bin/bash

set -euo pipefail

./aks_tap_login.sh "$1" "$2"
./install_certs_mac.sh
./add_git_repo_support.sh
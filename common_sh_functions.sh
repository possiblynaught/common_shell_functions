#!/bin/sh
# POSIX-compatible common functions for:
#   err()
#   random_number()
#   check_installed()

: <<'END_COMMENT'
################# TO ADD THESE FUNCTIONS TO YOUR SHELL SCRIPT ##################
# Add the submodule to your git repo with:
git submodule add https://github.com/possiblynaught/common_shell_functions.git
git submodule update --init --recursive

# Source the shell functions:
SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"
common_functions="$SCRIPT_DIR/common_shell_functions/common_sh_functions.sh"
if [ ! -d "$(dirname "$common_functions")" ]; then
  echo "You may need to add the submodule with:
  git submodule add https://github.com/possiblynaught/common_shell_functions.git
  git submodule update --init --recursive"
  exit 1
elif [ ! -x "$common_functions" ]; then
  git submodule update --init --recursive
fi
# shellcheck source=/dev/null
source "$common_functions"
################################################################################
END_COMMENT

# Error handler
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  exit 1
}

# Get a random, positive number between args $1 and $2 (inclusive)
# Ex: to get a random number with the smallest being 3 and largest being 9, run:
#   random_number "3" "9"
random_number() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    err "Error in random_number(), one or more args missing within: $(basename "$0")"
  elif [ "$1" -ge "$2" ] || [ "$1" -lt 0 ] || [ "$2" -lt 1 ]; then
    err "Error in random_number(), one or more args are illegal or negative"
  fi
  rand="$(tr -cd '1-9' < /proc/sys/kernel/random/uuid | \
    head -c 1)$(tr -cd '0-9' < /proc/sys/kernel/random/uuid | head -c "${#2}")"
  if [ "$rand" -lt "$2" ]; then
    err "Error in random_number(), random seed smaller than desired max val"
  fi
  echo "$(( rand % ( $2 - $1 + 1 ) + $1 ))"
}

# Check for each package passed as an arg and attempt to install it if missing.
# Some commands are subsets of packages with different names. To handle this,
# pass 'command|package' as an arg. Ex: for sponge, 'sponge|moreutils'
check_installed() {
  missing_pkgs=""
  for pkg in "$@"; do
    if echo "$pkg" | grep -qF "|" && ! command -v "$(echo "$pkg" | cut -d "|" -f1)" > /dev/null 2>&1; then
      temp_pkg="$(echo "$pkg" | cut -d "|" -f2)"
      missing_pkgs="${missing_pkgs:+${missing_pkgs} }${temp_pkg}"
    elif ! command -v "$pkg" > /dev/null 2>&1; then
      missing_pkgs="${missing_pkgs:+${missing_pkgs} }${pkg}"
    fi
  done
  if [ -n "$missing_pkgs" ]; then
    if command -v sudo > /dev/null 2>&1; then
     su_str="sudo"
    else
     su_str=""
    fi
    if command -v apt-get > /dev/null 2>&1; then
      $su_str apt-get update
      $su_str apt-get install -y $missing_pkgs
    elif command -v dnf > /dev/null 2>&1; then
      $su_str dnf update
      $su_str dnf install -y $missing_pkgs
    else
      err "Error, failed to install missing packages, install the following and try again:
    $missing_pkgs"
    fi
  fi
}

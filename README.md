# Common Shell Functions

Helpful shell functions to add to a git repo

## INSTALL

Add as a submodule to your repo:

```bash
git submodule add https://github.com/possiblynaught/common_shell_functions.git
git submodule update --init --recursive
```

## USE

Include in a shell script within the repo by adding this to the top of the file:

```bash
# Source common shell functions
SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"
common_functions="$SCRIPT_DIR/common_shell_functions/common_sh_functions.sh"
if [ ! -d "$(dirname "$common_functions")" ]; then
  echo "You may need to add the submodule with:
  git submodule add https://github.com/possiblynaught/common_shell_functions.git
  git submodule update --init --recursive"
  exit 1
elif [ ! -x "$common_functions" ]; then
  temp_dir="$PWD"
  cd "$SCRIPT_DIR" && git submodule update --init --recursive
  cd "$temp_dir"
fi
# shellcheck source=/dev/null
source "$common_functions"
```

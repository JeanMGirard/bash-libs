# Filesystem

Snippets

- [Filesystem](#filesystem)
    - [Check if file exists](#check-if-file-exists)
    - [current file directory](#current-file-directory)
    - [itterate over file](#itterate-over-file)
    - [Symbolic links](#symbolic-links)





-------------------------------------------------------------------------
### Check if file exists

```shell
if [[ -f "file" ]]; then echo "file exists"; fi
if [ -d "$HOME/.local/bin" ] ; then PATH="$HOME/.local/bin:$PATH"; fi
```

-------------------------------------------------------------------------
### current file directory

```shell
# for scripts in $PATH
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# for fully named scripts
SCRIPT_DIR="$(dirname "$0")"
# to resolve symlinks
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd );  SOURCE=$(readlink "$SOURCE");
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE 
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
```

--------------------------------------------847-----------------------------
### itterate over file

```shell
for filename in ./subdir/*.tf; do echo "$filename"; fi
```

-------------------------------------------------------------------------
### Symbolic links

```shell
mkdir -p "$HOME/.wsl" "$HOME/projects"

#  ln -sf     filepath                            symbolic_link
ln -sf        /mnt/a                              $HOME/.wsl/projects
ln -sf        /mnt/e/Clouds/OneDrive/Desktop      $HOME/.wsl/desktop
ln -sf        /mnt/c/Users/jm                     $HOME/.wsl/home
ln -sf        /mnt/a/JeanMGirard/infrastructures  $HOME/projects/infrastructures
```

-------------------------------------------------------------------------
###

```shell

```

-------------------------------------------------------------------------
###

```shell

```

-------------------------------------------------------------------------

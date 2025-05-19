# dotfiles
## Install

The Chezmoi install script is vendored in `scripts/chezmoi-install.sh` to reduce
the risk of upstream changes breaking the deploy. This script is wrapped by `install.sh` with pre-set parameters.

```shell
sh -c "$(curl -fsLS https://github.com/linuxdaemon/dotfiles/raw/refs/heads/master/install.sh)"
```

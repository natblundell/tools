# Miscellaneous Tools

## Multi-Dropbox

Wrapper allowing multiple Dropbox instances to run simultaneously.

Support for multiple linked Dropbox accounts is native in Windows, but sadly
not available under Linux - this script provides something similar. It is
designed as an aid to people who have both home and professional Dropbox
accounts.

It will also allow you to have multiple Dropbox instances running for
_unlinked_ accounts.

The "Primary Dropbox" is spawned normally, subsequent ones are started in fake
home directories. Each instance must be logged in and configured individually.

Usage:

```bash
$ multi-dropbox.sh --help
$ multi-dropbox.sh start

# Log in and configure each instance

$ multi-dropbox.sh symlinks # Optional

$ multi-dropbox.sh status
```

On first start of a new instance Dropbox will go through the process of
downloading its binaries and signing in. It is recommended that you pay close
attention to the console where you ran `multi-dropbox.sh` as it will tell you
which instance you signing in for.

If you are unsure, do each account one at a time:

```bash
# Set up the primary
$ DROPBOXES= multi-dropbox.sh start

# Set up the first secondary instance
$ DROPBOXES=FirstInstance multi-dropbox.sh start

# Set up the second secondary instance
$ DROPBOXES=FirstInstance SecondInstance multi-dropbox.sh start
...
```

### Configuring

Optionally the environment variables below can be defined:

- `DROPBOX` the path of the Dropbox executable. E.g.

  ```bash
  DROPBOX=/opt/bin/dropbox multi-dropbox.sh start
  ```

  Default value is `/usr/bin/dropbox`.

- `DROPBOXES` space separated list of _additional_ Dropbox names. Note that
  the a primary is always started E.g.

  ```bash
  DROPBOXES=DropboxWork DropboxShared
  ```

  Default value is `Dropbox-Work`. If you want something different, it is
  recommended that you add to the config file `~/.multi-dropbox-rc` which is
  read by `multi-dropbox.sh`, thus:

  ```bash
  echo "DROPBOXES=\"DropboxWork DropboxShared\"" >> ~/.multi-dropbox-rc
  ```

### Actions on specific instances

For the primary instance, just use Dropbox as you normally would, for example:

```bash
dropbox throttle unlimited auto
```

For secondary instances we must fool the Dropbox client into using the
secondary install. Executing `multi-dropbox.sh homes` will display the command
required to execute Dropbox for each instance:

```bash
$ multi-dropbox.sh homes
HOME="/home/nat/.multi-dropbox/Dropbox-Work" /usr/bin/dropbox

$ HOME="/home/nat/.multi-dropbox/Dropbox-Work" /usr/bin/dropbox exclude list
...
```

## git-prune.sh

Simple shell script for removing local branches that have been removed from the
origin.

```bash
git-prune.sh
```

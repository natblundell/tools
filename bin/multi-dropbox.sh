#!/bin/bash

# Multi-Dropbox by Nat Blundell <nat@tepic.co.uk>
#
# Copyright 2016-2019 Nat Blundell. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.


MULTI_RC=$HOME/.multi-dropbox-rc
if [[ -e "$MULTI_RC" ]] ; then
    source "$MULTI_RC"
fi

DROPBOX=${DROPBOX:-/usr/bin/dropbox}
DROPBOXES=${DROPBOXES:-Dropbox-Work}
MULTI_HOME=$HOME/.multi-dropbox


md_usage() {
    # Display the CLI usage
   cat <<-EOF
	Usage: `basename $0` [COMMAND]
	Control multiple Dropbox instances with a single command.

	Commands are:
	  start      start all Dropbox instances (default command)
	  symlinks   create symbolic links in $HOME to each instance
	  stop       stop all Dropbox instances
	  status     give the status of each Dropbox instance
	  killall    forcibly stop ANY Dropbox instance
          homes      display the HOME=... required to use each instance
	EOF
}


# Initialise the Multi-Dropbox instances
md_start() {
    echo "Starting primary Dropbox..."
    $DROPBOX start -i

    for instance in $DROPBOXES; do
        echo "Starting secondary Dropbox '$instance'..."

        path=$MULTI_HOME/$instance
        if ! [ -d "$path" ]
        then
            mkdir -p "$path" 2> /dev/null
            ln -s "$HOME/.Xauthority" "$path/" 2> /dev/null
        fi
        HOME="$path" $DROPBOX start -i
    done

    md_symlinks
}


# Display the status of each Multi-Dropbox instance
md_status() {
    echo -n "Primary: "
    $DROPBOX status

    for instance in $DROPBOXES; do
        echo -n "$instance: "
        HOME="$MULTI_HOME/$instance" $DROPBOX status
    done
}


# Stop (cleanly) Multi-Dropbox instance
md_stop() {
    echo -n "Primary: "
    $DROPBOX stop

    for instance in $DROPBOXES; do
        echo -n "$instance: "
        HOME="$MULTI_HOME/$instance" $DROPBOX stop
    done
}


# Create symbolic links from the $HOME to the actual Dropbox folder within the
# Multi-Dropbox secondary accounts
md_symlinks() {
    for instance in $DROPBOXES; do
        path=$MULTI_HOME/$instance
        symlink=$HOME/$instance

        if ! [[ -e "$symlink" ]]; then
            dbfolder=`realpath $path/Dropbox*`
            if ! [[ -e "$dbfolder" ]]; then
                echo "Secondary instance '$instance' not initialised yet, skipping symbolic linking"
            else
                echo "Creating symbolic link '$symlink' -> '$dbfolder'"
                ln -s "$dbfolder" "$symlink"
            fi
        fi
    done
}


# Kill all `dropbox` processes
md_killall() {
    pids=`pidof dropbox`
    for pid in $pids; do
        echo "Killing proces $pid"
        kill $pid
    done

    if [[ "" != $pids ]] ; then
        sleep 1
        pids=`pidof dropbox`
        if [[ "" != $pids ]] ; then
            echo "Processes $pids still running"
        fi
    fi
}


# Display HOME of each instance
md_homes() {
    for instance in $DROPBOXES; do
        echo "HOME=\"$MULTI_HOME/$instance\" $DROPBOX"
    done
}



# Check we have a Dropbox exec
if ! [ -e $DROPBOX ]; then
    echo "Dropbox executable '$DROPBOX' not found."
    exit 1
fi


if [[ $# -lt 1 ]]; then
    CMD=start
else
    CMD=$1
fi

case "$CMD" in

    start) md_start
          ;;

    stop) md_stop
          ;;

    status) md_status
            ;;

    symlinks) md_symlinks
              ;;

    killall) md_killall
             ;;

    homes) md_homes
           ;;

    *) md_usage
       exit 1
       ;;
esac

exit 0

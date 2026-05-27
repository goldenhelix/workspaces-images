#!/usr/bin/env bash
set -ex

# Wait for the desktop to be ready
/usr/bin/desktop_ready

for f in $HOME/Desktop/*.desktop; do
    chmod +x "$f"; gio set -t string "$f" metadata::xfce-exe-checksum "$(sha256sum "$f" | awk '{print $1}')"
done

# Set default arguments and allow override via APP_ARGS env variable
DEFAULT_ARGS=""
ARGS=${APP_ARGS:-$DEFAULT_ARGS}

# Define the IGV start command
START_COMMAND="/opt/igv/igv.sh"

# Launch IGV
echo "Starting IGV Genome Browser with command: $START_COMMAND $ARGS"
eval "$START_COMMAND $ARGS" &

# Store the PID of the java process
sleep 3
IGV_PID=$(pgrep -f "java.*igv")

# Only do process monitoring if env variable is set
if [ -n "$MONITOR_PROCESS" ]; then
    echo "Entering process monitoring loop"
    set +x
    while true
    do
        # Check if the java process for IGV is still running
        if ! ps -p $IGV_PID > /dev/null
        then
            echo "IGV application not found, terminating xfce4 session"
            xfce4-session-logout --logout --fast
            break
        fi
        sleep 1
    done
    set -x
fi

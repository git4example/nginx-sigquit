#!/bin/sh
# This script creates a "wrapper process" that waits for a SIGTERM (15) signal
# and sends the correct SIGQUIT (3) signal instead. This is a workaround until
# Fargate 1.4 properly supports STOPSIGNAL directives

echo "Starting New Entrypoint"
ps -aux
sigterm_handler() {
  echo "Singal trapped"
  if [ $pid -ne 0 ]; then
    # The if statement above makes sure that the nginx process is actually
    # established and running. This prevents attempting to wait on a non
    # existent pid, which would not work.
    echo "Sending SIGQUIT Singal"
    kill -3 $pid
    wait $pid
    # This sends the SIGQUIT (3) signal to nginx then waits for nginx to gracefully exit
  fi
  exit 131 # 128 + 3 = SIGQUIT
}

echo "Setting up for trap"
trap 'sigterm_handler' TERM
# This tells the script to call the above function when it gets a SIGTERM (15) signal

# The below command is verbose, and probably redundant, but TL;DR:
# 1. Redirect the output of the stdout for the command to the stdout of this process
# 2. Redirect the output of the stderr for the command to the stderr of this process
# 3. Run the /docker-entrypoint.sh script
# 4. Pass it the arguments that were passed to this command.
# 5. Run it in the background
echo "Setting STDOUT/STDERR and starting docker-entrypoint.sh"
1>/proc/$$/fd/1 2>/proc/$$/fd/2 /docker-entrypoint.sh "$@" &
ps -aux
# Now the command is running in the background we can capture the Process ID (PID)

pid="$!"
echo "PID : " $pid
# At this point we're done, but we need to put this script into a "sleep" state where it
# listens for signals, either due to the child process exits, or a parent process (i.e.
# docker) gives it a signal.
wait "$pid"

# If this "wait" command exits, then we need to pass the return code we got from our child
# to correctly reflect things.

exit "$?"

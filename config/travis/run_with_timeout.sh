#!/bin/bash
#
# Script to run commands on a Travis-CI test VM that otherwise would time out
# after 10 minutes. This replaces travis_wait and outputs stdout of the command
# running.

# Exit on error.
set -e

# Usage: ./run_with_timeout.sh [TIMEOUT] [COMMAND] [OPTION] [...]

TIMEOUT=$1;
shift

# Launch a command in the background.
$* &

PID_COMMAND=$!;

# Probe the command every minute.
MINUTES=0;

while kill -0 ${PID_COMMAND} >/dev/null 2>&1;
do
	# Print to stdout, seeing this prints a space and a backspace
	# there is no visible trace.
	echo -n -e " \b";

	if test ${MINUTES} -ge ${TIMEOUT};
	then
		kill -9 ${PID_COMMAND} >/dev/null 2>&1;

		echo -e "\033[0;31m[ERROR] command: $* timed out after: ${MINUTES} minute(s).\033[0m";

		exit 1;
	fi
	MINUTES=$(( ${MINUTES} + 1 ));

	sleep 60;
done

wait ${PID_COMMAND};

exit $?;

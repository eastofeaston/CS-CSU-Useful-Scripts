#!/bin/bash

# ! Requires real tabs for indentation, heredoc used. !

function usage {
	cat <<-EOF

	$0: a script to turn off/on GlobalProtect services.

	! Make sure you run start before trying to use the VPN again !

	usage: $0 start|stop
	       start: turn on GlobalProtect
	       stop: turn off GlobalProtect
	
	EOF
}

function start {
	launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*
}

function stop {
	launchctl unload /Library/LaunchAgents/com.paloaltonetworks.gp.pangp*
}

if [ "$#" -ne 1 ]; then
	usage
	exit 1
fi

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	*)
		usage
		exit 2
		;;
esac
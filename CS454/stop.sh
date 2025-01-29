#!/bin/bash

# ! Requires real tabs for the heredoc to work properly !

# Check if cs454 container has not been deployed
name=$(docker ps --format "{{.Image}} {{.Names}}" | grep cs454 | awk '{print $2}')
if [ -z "$name" ]; then
	cat <<-EOF
		No cs454 container found. 
		Please run deploy.sh first.
		EOF
	exit 1
fi

printf "Stopping %s...\n" "$name"

if docker container stop "$name" 1> /dev/null; then
	echo "OK"
fi
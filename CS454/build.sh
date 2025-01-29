#!/bin/bash

# ! Requires real tabs for the heredoc to work properly !
# ! Requires Dockerfile in the same dir as this script ! 

# Check if Dockerfile exists
if [ ! -f "$(dirname "$0")/Dockerfile" ]; then
    printf "Dockerfile not found in %s\n" "$(dirname "$0")"
    exit 1
fi

# Check if cs454 currently running
name=$(docker ps --format "{{.Image}} {{.Names}}" | grep cs454 | awk '{print $2}')
if [ -n "$name" ]; then
	cat <<-EOF
		Container $name using image cs454 is already running. 
		Please run stop.sh first.
		EOF
	exit 2
fi

# Build the image
docker build -t cs454 "$(realpath "$(dirname "$0")")"
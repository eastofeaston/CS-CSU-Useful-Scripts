#!/bin/bash

# ! Requires real tabs for the heredoc to work properly !

# Check if cs454 image exists
if [ -z "$(docker images -q cs454)" ]; then
	cat <<-EOF
		No cs454 image found. Please run build.sh first.
		EOF
	exit 1
fi

# Check if cs454 container is already running
name=$(docker ps --format "{{.Image}} {{.Names}}" | grep cs454 | awk '{print $2}')
if [ -n "$name" ]; then
	cat <<-EOF
		Container $name is already running with image cs454. 
		Please run stop.sh first.
		EOF
	exit 2
fi

# Run the container with Ravi's options
if docker run -d --rm --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 -p 8012:8012 -v "$(pwd)":/home/cs454 cs454 1> /dev/null; then
	name=$(docker ps --format "{{.Image}} {{.Names}}" | grep cs454 | awk '{print $2}')
	cat <<-EOF
		Launched container $name with image cs454.
		Container running: http://localhost:8012/
		EOF
fi
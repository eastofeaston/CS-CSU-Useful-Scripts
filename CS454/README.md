# CS454

These are built to work with Ravi's Dockerfile for the class.
I'd imagine you'll have already built out similar tooling yourself, but I figure
having mine out there might give someone a leg up.

## build.sh

Builds the cs454 image using the Dockerfile in the same directory.
*You will need to source this from the class, I am not giving it to you.* 

## deploy.sh

Deploys a new container using the cs454 image you've built. This will link the 
current working directory as your home for the container.

## attach.sh

Attaches to the running cs454 container with an interactive bash shell.

## stop.sh

Stops the running cs454 container.
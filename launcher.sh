#!/bin/bash

CONTAINER_NAME=steam_proton

# Choosing the right GPU type to share the right device.
GPU_DEVICE_PARAMETERS=""
source $(dirname "$0")/gpu.sh
[ "$GPU_TYPE" = NVIDIA ] && GPU_DEVICE_PARAMETERS="--device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia0"
[ "$GPU_TYPE" = INTEL ] && GPU_DEVICE_PARAMETERS="--device=/dev/dri:/dev/dri"

# Creating the shared_directory if necessary.
[ -d shared_directory ] || mkdir shared_directory

# The following line mounts the shared directory inside of the container.

( \
	echo 'Trying to run a new data container.' && \
	sudo docker run -it \
			-e DISPLAY \
			-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
			-v ~/.Xauthority:/home/proton/.Xauthority \
			--ipc="host" \
			--device=/dev/snd:/dev/snd \
			$GPU_DEVICE_PARAMETERS \
			-v /run/user/`id -u`/pulse/native:/run/user/`id -u`/pulse/native \
			-v `pwd`/shared_directory:/home/proton/shared_directory \
			--net=host \
			--restart=no \
			--name "$CONTAINER_NAME" \
			webanck/docker-steam-proton \
	2>/dev/null \
) || ( \
	echo 'The container already exists, relaunching the old one.' && \
	sudo docker start -ai "$CONTAINER_NAME" \
)

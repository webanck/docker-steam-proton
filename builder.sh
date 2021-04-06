#!/bin/bash

# Choosing the right GPU type to install the right driver (see the Dockerfile).
source $(dirname "$0")/gpu.sh

# Getting the user id.
MYUID=$(id -u)

TMP_DIR=/tmp/docker-wine-steam

# Temporary copies of files to be included in image.
mkdir $TMP_DIR 
cp -f Dockerfile $TMP_DIR/ && cp -f finalize_installation.sh $TMP_DIR/

# Building the image.
sudo docker build -t webanck/docker-wine-steam --build-arg WINE_USER_UID=$MYUID --build-arg GPU_TYPE=$GPU_TYPE $TMP_DIR/ 

# Cleaning up.
rm $TMP_DIR/Dockerfile $TMP_DIR/finalize_installation.sh

#!/bin/bash
# File: setup.sh
# Author: Seongeun Kim (eunbelivable@snu.ac.kr)

# Variables
DOCKER_ID="seamustard52"
PREFIX="introbioinfo"
EXERCISE_NAME="exercise06"
EXERCISE_DIR=$PWD

# Run docker
docker run -it --mount type=bind,src=$PWD,target=/home/$EXERCISE_NAME/$EXERCISE_NAME \
--name $EXERCISE_NAME "$DOCKER_ID/$PREFIX-$EXERCISE_NAME"

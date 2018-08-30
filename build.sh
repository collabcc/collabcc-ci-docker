#!/usr/bin/env bash

set -xe

if [ -z "$OS_NAME" ]; then
    echo "Unexpected: OS_NAME is empty"
    exit 1
fi
if [ -z "$OS_VER" ]; then
    echo "Unexpected: OS_VER is empty"
    exit 1
fi

# Install jq if necessary
if ! hash jq; then
    sudo apt -yqq update
    sudo apt install -yqq jq
fi

# Check if we needed build
# Use skopeo project
sudo docker pull alexeiled/skopeo
base="$(sudo docker run --rm alexeiled/skopeo skopeo inspect "docker://docker.io/$OS_NAME:$OS_VER" | jq -r '.Layers[-1]')"
expect="$(sudo docker run --rm alexeiled/skopeo skopeo inspect "docker://docker.io/collabccci/$OS_NAME:$OS_VER" | jq -r '.Layers[-2]')"
if [ "$base" = "$expect" ]; then
    echo "Image $OS_NAME:$OS_VER is latest. Do nothing."
    exit 0
fi


echo "$DOCKER_PASSWORD" | sudo docker login --username "collabcc" --password-stdin

rm -rf build
mkdir build
cd build
cmake ..
cmake --build .


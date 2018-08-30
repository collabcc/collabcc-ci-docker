#!/usr/bin/env bash

set -xe

echo "$DOCKER_PASSWORD" | sudo docker login --username "collabcc" --password-stdin

rm -rf build
mkdir build
cd build
cmake ..
cmake --build .


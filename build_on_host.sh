#!/bin/bash

set -ex;

org='protocolbuffers'
proj='protobuf'

docker_build() {
    local version=$(curl -s https://api.github.com/repos/${org}/${proj}/releases/latest | jq -r ".tag_name")
    local builder="${org}-${proj}-builder"
    local version=${version#v}
    docker build -t ${builder} .
    docker run --rm -v$(pwd):/workspace -e PROTOBUF_VERSION=${version} ${builder}
    docker rmi ${builder}
}

docker_build

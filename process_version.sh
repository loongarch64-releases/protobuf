#!/bin/bash
set -exuo pipefail

readonly version="$1"

readonly org='protocolbuffers'
readonly proj='protobuf'
readonly arch='loongarch64'
readonly goarch='loong64'
readonly proj_name="${proj}-${version}"

# 映射目录
readonly workspace="/workspace"
readonly dists="${workspace}/dists"
readonly patches="${workspace}/patches"

readonly build="/build"
readonly source_root="${build}/${proj_name}"
readonly build_root="${build}/${proj_name}"
readonly package_root="${dists}/${proj_name}"

mkdir -p "${build}"


apply_patches()
{
    for patch_ in ${patches}/*.patch;
    do
        git apply ${patch_}
    done
}

fetch_source_code()
{
    rm -rf "${source_root}"
    git clone --branch "v${version}" --depth=1 "https://github.com/${org}/${proj}" "${source_root}"
}

build(){
    pushd "${build_root}"
        mkdir build
        mkdir /dist_static
        cd build
        cmake -G "Unix Makefiles" \
            -DCMAKE_BUILD_TYPE=Release \
            -Dprotobuf_BUILD_TESTS=OFF \
            -Dprotobuf_MSVC_STATIC_RUNTIME=ON \
            -DCMAKE_EXE_LINKER_FLAGS="-static" \
            -DCMAKE_INSTALL_PREFIX=/dist_static \
            ..
        make -j`nproc`
        make install
    popd
}

package(){
    rm -rf "${package_root}"
    mkdir -p "${package_root}"
    pushd "${package_root}"
        mkdir bin
        mkdir -p include/google/protobuf/compiler
        cp /dist_static/bin/protoc bin/
        cp /dist_static/include/google/protobuf/*.proto include/google/protobuf/
        cp /dist_static/include/google/protobuf/compiler/*.proto include/google/protobuf/compiler/
        zip -r protoc-${version}-linux-loongarch64.zip  bin/ include/
        rm -rf bin include

	# 静态开发产物，用于构建 protoc-gen-grpc-java 等原生插件
        dev_items="include lib"
        [ -d /dist_static/lib64 ] && dev_items="$dev_items lib64"
        for d in $dev_items; do
            cp -a "/dist_static/$d" .
        done
        zip -r "protobuf-${version}-loongarch64-dev.zip" $dev_items
        rm -rf $dev_items
    popd

}

main()
{
    fetch_source_code
    build
    package
}

main "$@"

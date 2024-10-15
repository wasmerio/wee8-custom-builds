#!/bin/bash

# Display all commands before executing them.
set -o errexit
set -o errtrace

V8_REPO_URL=${2:-https://github.com/laper32/v8-cmake.git}
LLVM_CROSS="$3"

if [[ -z "$V8_REPO_URL" ]]
then
  echo "Usage: $0 <v8-repository-url>"
  echo
  echo "# Arguments"
  echo "  v8-repository-url  The URL used to clone v8-cmake sources (default: $V8_REPO_URL)"

  exit 1
fi

if [ ! -d v8-cmake ]
then
	git clone -b "msvc" --single-branch --depth=1 "$V8_REPO_URL" v8-cmake
fi

cd v8-cmake 

# Create a directory to build the project.
mkdir -p build
cd build

# Create a directory to receive the complete installation.
mkdir -p install

# Adjust compilation based on the OS.
CMAKE_ARGUMENTS=""

case "${OSTYPE}" in
    darwin*) ;;
    linux*) ;;
    *) ;;
esac

## Adjust cross compilation
#CROSS_COMPILE=""
#
#case "${LLVM_CROSS}" in
#    aarch64*) CROSS_COMPILE="-DLLVM_HOST_TRIPLE=aarch64-linux-gnu" ;;
#    riscv64*) CROSS_COMPILE="-DLLVM_HOST_TRIPLE=riscv64-linux-gnu" ;;
#    *) ;;
#esac

# Run `cmake` to configure the project.
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=MinSizeRel ..

# Showtime!
cmake --build . --config MinSizeRel --target wee8

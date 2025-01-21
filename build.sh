#!/bin/bash

# Display all commands before executing them.
set -o errexit
set -o errtrace
set -x

DEPOT_TOOLS_REPO="https://chromium.googlesource.com/chromium/tools/depot_tools.git"

if [ -z "$1" ]; then 
  case $(uname -m) in
	"x86_64")
	  ARCH="x64"
      ;;
  
	*)
	  ARCH=$(uname -m)
      ;;
  esac
else 
  ARCH=$1
fi

if [ -z "$2" ]; then 
  case $(uname -m) in
	*)
	  OS="unix"
	  ;;
  esac
else 
  OS=$2
fi


if [ ! -d depot_tools ]
then 
  git clone --single-branch --depth=1 "$DEPOT_TOOLS_REPO" /tmp/depot_tools
fi

export PATH="$PATH:/tmp/depot_tools"

# Set up google's client and fetch v8
if [ ! -d v8 ]
then 
  gclient 
  fetch --no-history v8
fi

cd v8

for patch in ../patches/*.patch; do 
  git apply "$patch"
done 

gn gen out/release --args="is_debug=false \
  v8_symbol_level=2 \
  is_component_build=false \
  is_official_build=false \
  use_custom_libcxx=false \
  use_custom_libcxx_for_host=true \
  use_sysroot=false \
  use_glib=false \
  is_clang=false \
  v8_expose_symbols=true \
  v8_optimized_debug=false \
  v8_enable_sandbox=false \
  v8_enable_i18n_support=false \
  v8_enable_gdbjit=false \
  v8_use_external_startup_data=false \
  treat_warnings_as_errors=false \
  target_cpu=\"$ARCH\"
  v8_target_cpu=\"$ARCH\"
  target_os=\"$OS\"
  "

# Showtime!
ninja -C out/release wee8

ls -laR out/release/obj

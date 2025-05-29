#!/bin/bash

# Display all commands before executing them.
set -o errexit
set -o errtrace
set -x

DEPOT_TOOLS_REPO="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
DEPOT_TOOLS_DIR="/tmp/depot_tools"
CURRENT_DIR=$(pwd)

DEPOT_TOOLS_COMMIT=${DEPOT_TOOLS_COMMIT:-"e803e2cb4b7bfb45924b255f2f2ae8352d2f582a"}
V8_COMMIT=${V8_COMMIT:-"fdf194e36193ed76abe21153360fd502f05f105d"} # 13.5.156

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
  case $(uname -s) in
	"Darwin")
	  OS="mac"
	  ;;
	"Linux")
	  OS="linux"
	  ;;
	*)
	  OS=$(uname -s)
  esac
else 
  OS=$2
fi


if [ ! -d "$DEPOT_TOOLS_DIR" ]
then 
  git clone "$DEPOT_TOOLS_REPO" "$DEPOT_TOOLS_DIR"
fi

cd "$DEPOT_TOOLS_DIR"
git checkout "$DEPOT_TOOLS_COMMIT"
export PATH="$PATH:$DEPOT_TOOLS_DIR"

cd "$CURRENT_DIR"

gclient

# Set up google's client and fetch v8
if [ ! -d v8 ]
then 
  fetch v8
  if [ "$OS" == "android" ] 
  then
	echo "target_os = [\"android\"];" >> .gclient
	gclient sync
  fi
  if [ "$OS" == "ios" ] 
  then
	echo "target_os = [\"ios\"];" >> .gclient
	gclient sync
  fi
fi

cd v8
git reset --hard
git checkout "$V8_COMMIT"

for patch in ../patches/*.patch; do 
  git apply "$patch"
done

if [ "$OS" == "ios" ]
then
gn gen out/release --args="is_debug=false \
  v8_symbol_level=0 \
  symbol_level = 0 \
  is_component_build=false \
  is_official_build=false \
  use_custom_libcxx=false \
  use_custom_libcxx_for_host=false \
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
  v8_enable_fast_mksnapshot = true \
  v8_enable_handle_zapping = false \
  target_cpu=\"$ARCH\" \
  v8_target_cpu=\"$ARCH\" \
  target_os=\"$OS\" \
  target_environment=\"device\" \
  "
else 
gn gen out/release --args="is_debug=false \
  v8_symbol_level=0 \
  symbol_level = 0 \
  is_component_build=false \
  is_official_build=false \
  use_custom_libcxx=false \
  use_custom_libcxx_for_host=false \
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
  v8_enable_fast_mksnapshot = true \
  v8_enable_handle_zapping = false \
  target_cpu=\"$ARCH\" \
  v8_target_cpu=\"$ARCH\" \
  target_os=\"$OS\" \
  "
fi
# Showtime!
ninja -C out/release wee8

ls -laR out/release/obj

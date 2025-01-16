#!/bin/bash

# Display all commands before executing them.
set -o errexit
set -o errtrace
set -x

DEPOT_TOOLS_REPO="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
ARCH=${3:-$(uname -m)}

if [ ! -d depot_tools ]
then 
  git clone --single-branch --depth=1 "$DEPOT_TOOLS_REPO" depot_tools
fi

export PATH="$(pwd)/depot_tools:$PATH"

# Set up google's client and fetch v8
gclient && fetch v8 --no-history

cd v8

gn gen out/release --args="is_component_build=false  \
  v8_monolithic=true v8_static_library=true  \ 
  is_clang=false  \
  is_asan=false \
  is_debug=false \
  is_official_build=false \
  v8_enable_sandbox=false \
  treat_warnings_as_errors=false \
  clang_use_chrome_plugins=false \
  v8_enable_i18n_support=false \
  v8_use_external_startup_data=false \
  use_custom_libcxx=false \
  use_sysroot=false \
  v8_enable_slow_dchecks=false \
  v8_dcheck_always_on=false \
  v8_enable_fast_mksnapshot=true \
  target_cpu=\"$ARCH\""

# Showtime!
ninja -C out/release

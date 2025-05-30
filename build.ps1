$DEPOT_TOOLS_REPO="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
$V8_TAG="13.5.156"

# Clone depot-tools
if (-not (Test-Path -Path "depot_tools" -PathType Container)) {
  git clone --single-branch --depth=1 "$DEPOT_TOOLS_REPO" "C:\tmp\depot_tools"
}

echo "C:\tmp\depot_tools" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
$env:Path = "C:\tmp\depot_tools;" + $env:Path

# Set up google's client and fetch v8
if (-not (Test-Path -Path "v8" -PathType Container)) {
  gclient 
  fetch v8
}

Set-Location v8

git checkout $V8_TAG 
gclient sync --with_branch_heads --with_tags

# Apply patches

$files = Get-ChildItem "../patches" -Filter *.patch 
foreach ($f in $files){
  git apply $f
}

gn gen out/release --args="is_debug=false v8_symbol_level=2 is_component_build=false is_official_build=false use_custom_libcxx=false use_custom_libcxx_for_host=true use_sysroot=false use_glib=false is_clang=false v8_expose_symbols=true v8_optimized_debug=false v8_enable_sandbox=false v8_enable_i18n_support=false v8_enable_gdbjit=false v8_use_external_startup_data=false 
  treat_warnings_as_errors=false target_cpu=\"$ARCH\" v8_target_cpu=\"$ARCH\" target_os=\"$OS\""

# Showtime!
ninja -C out/release wee8

ls -laR out/release/obj

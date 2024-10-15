$V8_REPO_URL = $args[1]

if ([string]::IsNullOrEmpty($V8_REPO_URL)) {
    $V8_REPO_URL = "https://github.com/laper32/v8-cmake.git"
}

# Clone the LLVM project.
if (-not (Test-Path -Path "v8-cmake" -PathType Container)) {
	git clone -b "msvc" --single-branch --depth=1 "$V8_REPO_URL" v8-cmake
}

Set-Location v8-cmake 
git fetch origin

# Create a directory to build the project.
New-Item -Path "build" -Force -ItemType "directory"
Set-Location build

# Create a directory to receive the complete installation.
New-Item -Path "install" -Force -ItemType "directory"

# Adjust compilation based on the OS.
$CMAKE_ARGUMENTS = ""

# Adjust cross compilation
$CROSS_COMPILE = ""

# Run `cmake` to configure the project, using MSVC.
$CMAKE_CXX_COMPILER="cl.exe"
$CMAKE_C_COMPILER="cl.exe"
$CMAKE_LINKER_TYPE="MSVC"

cmake -G "Ninja" -DCMAKE_BUILD_TYPE=MinSizeRel  ..

# Showtime!
cmake --build . --config MinSizeRel --target wee8

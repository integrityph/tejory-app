#!/bin/bash
set -e

# --- Configuration ---
# The name of the submodule directory containing the secp256k1 source code.
SUBMODULE_DIR="secp256k1" 

IOS_MIN_SDK_VERSION="13.0" # Minimum iOS version to support
BASE_DIR=$(pwd) # This will be your main project folder
SOURCE_DIR="${BASE_DIR}/${SUBMODULE_DIR}" # Path to the secp256k1 source

# Place all build artifacts in a 'build' directory in your main project folder.
OUTPUT_DIR="${BASE_DIR}/build"
mkdir -p "${OUTPUT_DIR}"

# --- Build Function ---
build_for_arch() {
    ARCH=$1
    SDK=$2
    HOST_TRIPLE=$3

    CLANG_TARGET="${ARCH}-apple-ios${IOS_MIN_SDK_VERSION}"
    if [ "$SDK" == "iphonesimulator" ]; then
        CLANG_TARGET="${CLANG_TARGET}-simulator"
    fi

    echo "---"
    echo "Building for ARCH=${ARCH} SDK=${SDK}"
    echo "---"

    # Temporarily change into the submodule directory to run configure/make
    cd "${SOURCE_DIR}"

    CURRENT_SDKROOT=$(xcrun --sdk ${SDK} --show-sdk-path)
    CLANG=$(xcrun --sdk ${SDK} -f clang)

    CURRENT_CFLAGS="-arch ${ARCH} -isysroot ${CURRENT_SDKROOT} -miphoneos-version-min=${IOS_MIN_SDK_VERSION} -target ${CLANG_TARGET} -fembed-bitcode -fPIC"
    CURRENT_LDFLAGS="-L${CURRENT_SDKROOT}/usr/lib -target ${CLANG_TARGET}"

    ASM_CONFIGURE_FLAG="--disable-asm"
    if { [ "$ARCH" == "x86_64" ] && [ "$SDK" == "iphonesimulator" ]; } || \
       { [ "$ARCH" == "arm64" ] && [ "$SDK" == "iphoneos" ]; }; then
        ASM_CONFIGURE_FLAG="--enable-asm"
    fi

    if [ -f "Makefile" ]; then make distclean || true; fi
    rm -f config.cache

    ./autogen.sh
    CC="${CLANG}" CFLAGS="${CURRENT_CFLAGS}" LDFLAGS="${CURRENT_LDFLAGS}" \
    ./configure \
        --host="${HOST_TRIPLE}" \
        --enable-module-recovery \
        --disable-shared \
        --enable-static \
        ${ASM_CONFIGURE_FLAG} \
        --with-pic

    make -j$(sysctl -n hw.ncpu)

    # The destination path for the .a file needs the full path to the parent's build directory
    cp ".libs/libsecp256k1.a" "${OUTPUT_DIR}/libsecp256k1-${ARCH}-${SDK}.a"
    echo "Successfully built libsecp256k1-${ARCH}-${SDK}.a"

    # Change back to the base directory when done
    cd "${BASE_DIR}"
}

# --- Compilation ---
build_for_arch "arm64" "iphoneos" "aarch64-apple-darwin"
build_for_arch "x86_64" "iphonesimulator" "x86_64-apple-darwin"
build_for_arch "arm64" "iphonesimulator" "aarch64-apple-darwin"

# --- LIPO: Create Universal Simulator Library ---
echo "Creating universal simulator library..."
lipo -create \
    "${OUTPUT_DIR}/libsecp256k1-x86_64-iphonesimulator.a" \
    "${OUTPUT_DIR}/libsecp256k1-arm64-iphonesimulator.a" \
    -output "${OUTPUT_DIR}/libsecp256k1-universal-simulator.a"

# --- Create XCFramework ---
echo "Creating XCFramework..."
rm -rf "${BASE_DIR}/secp256k1.xcframework"

xcodebuild -create-xcframework \
    -library "${OUTPUT_DIR}/libsecp256k1-arm64-iphoneos.a" \
    -headers "${SOURCE_DIR}/include" \
    -library "${OUTPUT_DIR}/libsecp256k1-universal-simulator.a" \
    -headers "${SOURCE_DIR}/include" \
    -output "${BASE_DIR}/secp256k1.xcframework"

echo "✅ Done! XCFramework created at ${BASE_DIR}/secp256k1.xcframework"
echo "You can now add this XCFramework to your Xcode project."
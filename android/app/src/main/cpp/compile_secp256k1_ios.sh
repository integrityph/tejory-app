#!/bin/bash
set -e

# --- Configuration ---
# The name of the submodule directory containing the secp256k1 source code.
SUBMODULE_DIR="secp256k1" 

IOS_MIN_SDK_VERSION="12.0" # Minimum iOS version to support
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

    # Temporarily change folder to the arch build folder
    # cd "${OUTPUT_DIR}/${ARCH}-${SDK}"
    cd "${SOURCE_DIR}"

    CURRENT_SDKROOT=$(xcrun --sdk ${SDK} --show-sdk-path)
    CLANG=$(xcrun --sdk ${SDK} -f clang)

    CURRENT_CFLAGS="-arch ${ARCH} -isysroot ${CURRENT_SDKROOT} -miphoneos-version-min=${IOS_MIN_SDK_VERSION} -target ${CLANG_TARGET} -fPIC -g"
    CURRENT_LDFLAGS="-L${CURRENT_SDKROOT}/usr/lib -target ${CLANG_TARGET}"

    if [ -f "${SOURCE_DIR}/Makefile" ]; then make distclean || true; fi
    rm -f config.cache

    ./autogen.sh
    CC="${CLANG}" CFLAGS="${CURRENT_CFLAGS}" LDFLAGS="${CURRENT_LDFLAGS}" \
    ./configure \
        --host="${HOST_TRIPLE}" \
        --enable-module-recovery \
        --enable-shared \
        --disable-static \
        --with-pic

    make -j$(sysctl -n hw.ncpu)

    DYLIB_FILE=".libs/libsecp256k1.dylib"

    echo "--- Fixing install_name for the dynamic library ---"
    install_name_tool -id "@rpath/secp256k1.framework/secp256k1" "${DYLIB_FILE}"

    # Instead of just copying the .dylib, we will create a full .framework bundle.
    FRAMEWORK_NAME="secp256k1"
    FRAMEWORK_DIR="${OUTPUT_DIR}/${ARCH}-${SDK}/${FRAMEWORK_NAME}.framework"
    
    echo "--- Creating .framework bundle at ${FRAMEWORK_DIR} ---"
    mkdir -p "${FRAMEWORK_DIR}/Headers"

    cat > "${FRAMEWORK_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>${FRAMEWORK_NAME}</string>
	<key>CFBundleIdentifier</key>
	<string>com.example.secp256k1</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>${FRAMEWORK_NAME}</string>
    <key>MinimumOSVersion</key>
	<string>${IOS_MIN_SDK_VERSION}</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
</dict>
</plist>
EOF

    # Copy the dylib into the framework
    cp ".libs/lib${FRAMEWORK_NAME}.dylib" "${FRAMEWORK_DIR}/${FRAMEWORK_NAME}"

    # The destination path for the .a file needs the full path to the parent's build directory
    mkdir -p "${OUTPUT_DIR}/${ARCH}-${SDK}"
    dsymutil "${DYLIB_FILE}" -o "${OUTPUT_DIR}/${ARCH}-${SDK}/${FRAMEWORK_NAME}.framework.dSYM"
    # cp "${DYLIB_FILE}" "${OUTPUT_DIR}/${ARCH}-${SDK}/libsecp256k1.dylib"
    echo "Successfully built ${ARCH}-${SDK}/libsecp256k1.dylib"

    cd "${SOURCE_DIR}"
    rm -rf .libs
    git clean -dxf

    # Change back to the base directory when done
    cd "${BASE_DIR}"
}

# --- Compilation ---
# build_for_arch "arm64" "iphonesimulator" "aarch64-apple-darwin"
build_for_arch "arm64" "iphoneos" "aarch64-apple-darwin"
build_for_arch "x86_64" "iphonesimulator" "x86_64-apple-darwin"


# --- LIPO: Create Universal Simulator Library ---
echo "Creating universal simulator library..."
# lipo -create \
#     "${OUTPUT_DIR}/arm64-iphoneos/libsecp256k1.dylib" \
#     "${OUTPUT_DIR}/x86_64-iphonesimulator/libsecp256k1.dylib" \
#     -output "${OUTPUT_DIR}/libsecp256k1.dylib"

# --- Create XCFramework ---
echo "Creating XCFramework..."
rm -rf "${BASE_DIR}/secp256k1.xcframework"

# xcodebuild -create-xcframework \
#     -library "${OUTPUT_DIR}/arm64-iphoneos/libsecp256k1.dylib" \
#     -headers "${SOURCE_DIR}/include" \
#     -library "${OUTPUT_DIR}/x86_64-iphonesimulator/libsecp256k1.dylib" \
#     -headers "${SOURCE_DIR}/include" \
#     -output "${BASE_DIR}/secp256k1.xcframework"

xcodebuild -create-xcframework \
    -framework "${OUTPUT_DIR}/arm64-iphoneos/secp256k1.framework" \
    -debug-symbols "${OUTPUT_DIR}/arm64-iphoneos/secp256k1.framework.dSYM" \
    -framework "${OUTPUT_DIR}/x86_64-iphonesimulator/secp256k1.framework" \
    -debug-symbols "${OUTPUT_DIR}/x86_64-iphonesimulator/secp256k1.framework.dSYM" \
    -output "${BASE_DIR}/secp256k1.xcframework"

rm -rf "${BASE_DIR}/build"

echo "✅ Done! XCFramework created at ${BASE_DIR}/secp256k1.xcframework"
echo "You can now add this XCFramework to your Xcode project."
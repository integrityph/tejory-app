cmake_minimum_required(VERSION 3.10.2)
project(main_crypto_libs)

# --- Step 1: Run the builder project ---
# This forces the OpenSSL build to complete BEFORE the rest of this script runs.
add_subdirectory(openssl_builder)

# --- Step 2: Link secp256k1 ---
add_subdirectory(secp256k1)

# --- Step 3: Define IMPORTED target for OpenSSL ---
# By the time this code is executed, the files are guaranteed to exist on disk.
set(OPENSSL_INSTALL_DIR ${CMAKE_BINARY_DIR}/openssl_prebuilt/${ANDROID_ABI}/out)
add_library(libcrypto SHARED IMPORTED)
set_target_properties(libcrypto PROPERTIES
    IMPORTED_LOCATION "${OPENSSL_INSTALL_DIR}/lib/libcrypto.so"
    INTERFACE_INCLUDE_DIRECTORIES "${OPENSSL_INSTALL_DIR}/include"
)

# --- Step 4: Create the final wrapper library ---
# (You still need the empty crypto_wrapper.cpp file)
add_library(
    crypto_bundle # This produces libcrypto_bundle.so
    SHARED
    crypto_wrapper.cpp
)

# --- Step 5: Link everything together ---
target_link_libraries(
    crypto_bundle
    # secp256k1
    libcrypto
)
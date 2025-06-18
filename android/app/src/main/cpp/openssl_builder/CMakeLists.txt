# This project's only purpose is to build OpenSSL and place the results
# in a predictable location. It is run first.

cmake_minimum_required(VERSION 3.10.2)
project(openssl_builder C)

# The final, clean directory for the compiled libraries and headers
set(OPENSSL_BUILD_DIR ${CMAKE_BINARY_DIR}/openssl_prebuilt/${ANDROID_ABI})
set(OPENSSL_INSTALL_DIR ${OPENSSL_BUILD_DIR}/out)

message(WARNING "XXXXXXXXXXXXX CFLAGS=${CFLAGS}")
message(WARNING "XXXXXXXXXXXXX LDFLAGS=${LDFLAGS}")
message(WARNING "XXXXXXXXXXXXX ANDROID_PLATFORM=${ANDROID_PLATFORM}")

# Only run the build if the library doesn't already exist for this ABI
if(NOT EXISTS ${OPENSSL_INSTALL_DIR}/lib/libcrypto.so)

    # --- This is your proven, working build script ---
    message(STATUS "OpenSSL prebuilt library not found for ${ANDROID_ABI}. Building now...")

    set(OPENSSL_SOURCE_DIR ${CMAKE_SOURCE_DIR}/openssl)

    if(${ANDROID_ABI} STREQUAL "arm64-v8a")
				set(OPENSSL_CONFIGURE_TARGET "android-arm64")
		elseif(${ANDROID_ABI} STREQUAL "armeabi-v7a")
				set(OPENSSL_CONFIGURE_TARGET "android-arm")
		elseif(${ANDROID_ABI} STREQUAL "x86_64")
				set(OPENSSL_CONFIGURE_TARGET "android-x86_64")
		elseif(${ANDROID_ABI} STREQUAL "x86")
				set(OPENSSL_CONFIGURE_TARGET "android-x86")
		else()
				message(FATAL_ERROR "Unsupported Android ABI: ${ANDROID_ABI}")
		endif()

    include(ProcessorCount)
    ProcessorCount(NPROCESSORS)
    set(ANDROID_TOOLCHAIN_BIN "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin")
		set(ENV_FLAGS "CFLAGS='${CMAKE_C_FLAGS}' LDFLAGS='${CMAKE_SHARED_LINKER_FLAGS}'")
		set(OPTIMIZED_CFLAGS "${CMAKE_C_FLAGS} -O2")

    execute_process(
        COMMAND /bin/sh -c "set -e; \
                            export PATH=${ANDROID_TOOLCHAIN_BIN}:$PATH; \
                            export ANDROID_NDK_ROOT=${CMAKE_ANDROID_NDK}; \
														echo \"EXECUTION SHELL CFLAGS is: ${CFLAGS}\"; \
														echo \"EXECUTION SHELL LDFLAGS is: ${LDFLAGS}\"; \
														mkdir -p ${OPENSSL_BUILD_DIR}; \
														mkdir -p ${OPENSSL_INSTALL_DIR}; \
                            cd ${OPENSSL_BUILD_DIR}; \
                            ${OPENSSL_SOURCE_DIR}/Configure ${OPENSSL_CONFIGURE_TARGET} -D__ANDROID_API__=24 no-apps no-asm no-docs no-engine no-gost no-legacy shared no-ssl no-tests no-zlib --release --prefix=${OPENSSL_INSTALL_DIR} --openssldir=${OPENSSL_INSTALL_DIR}; \
                            make -j${NPROCESSORS}; \
                            make install_sw"
				# COMMAND set -e
				# COMMAND export PATH=${ANDROID_TOOLCHAIN_BIN}:$PATH
				# COMMAND export ANDROID_NDK_ROOT=${CMAKE_ANDROID_NDK}
				# COMMAND mkdir -p ${OPENSSL_BUILD_DIR}
				# COMMAND mkdir -p ${OPENSSL_INSTALL_DIR}
				# COMMAND cd ${OPENSSL_BUILD_DIR}
				# COMMAND ${OPENSSL_SOURCE_DIR}/Configure ${OPENSSL_CONFIGURE_TARGET} no-apps no-asm no-docs no-engine no-gost no-legacy shared no-ssl no-tests no-zlib --prefix=${OPENSSL_INSTALL_DIR}
				# COMMAND make -j${NPROCESSORS}
				# COMMAND make install_s

        RESULT_VARIABLE result
        ERROR_VARIABLE error
				OUTPUT_VARIABLE out
    )

		message(WARNING "XXXXXXXXXXXXX out=${out}")

    if(NOT result EQUAL 0)
        message(FATAL_ERROR "Failed to build OpenSSL. Error: ${error}")
    endif()

else()
    message(STATUS "Found existing OpenSSL prebuilt library for ${ANDROID_ABI}. Skipping build.")
endif()



# TODO: implement this pattern
# ExternalProject_Add(
#     libcrypto_builder # A name for this build step

#     # Source code details
#     GIT_REPOSITORY    https://github.com/openssl/openssl.git
#     GIT_TAG           openssl-3.5.0 # A recent, stable version of OpenSSL

#     # Directory configuration
#     PREFIX            "${THIRD_PARTY_BUILD_DIR}/openssl"

#     # The command to configure OpenSSL. It runs the 'Configure' script.
#     # We explicitly pass the correct Android API level and architecture.
#     CONFIGURE_COMMAND <SOURCE_DIR>/Configure
#                       ${OPENSSL_ARCH}
#                       -D__ANDROID_API__=${CMAKE_ANDROID_API}
#                       shared # We want libcrypto.so
#                       no-apps no-tests no-ssl # We only need the crypto part
# 											--prefix=${THIRD_PARTY_BUILD_DIR}/openssl

#     # The command to build the library after configuration
#     BUILD_COMMAND     make -j${CMAKE_HOST_SYSTEM_PROCESSOR_COUNT}

#     # The command to copy the final library and headers to a clean install directory
#     INSTALL_COMMAND   make install_sw

#     # Suppress verbose output during the build for a cleaner log
#     LOG_CONFIGURE     1
#     LOG_BUILD         1
#     LOG_INSTALL       1
# )

cmake_minimum_required(VERSION 3.10.2)
# project(main_crypto_libs)

# Link secp256k1
add_subdirectory(secp256k1)

target_link_options(secp256k1 PRIVATE "-Wl,-z,max-page-size=0x4000")

# --- Step 3: Define IMPORTED target for OpenSSL ---
# By the time this code is executed, the files are guaranteed to exist on disk.

# # --- Step 4: Create the final wrapper library ---
# # (You still need the empty crypto_wrapper.cpp file)
# add_library(
#     crypto_bundle # This produces libcrypto_bundle.so
#     SHARED
#     crypto_wrapper.cpp
# )

# # --- Step 5: Link everything together ---
# target_link_libraries(
#     crypto_bundle
#     # secp256k1
#     libcrypto
# )


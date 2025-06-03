# android/app/src/main/cpp/CMakeLists.txt (Option A)
cmake_minimum_required(VERSION 3.10.2) # Match your NDK's supported CMake version

project(my_flutter_app_native_libs)

# This will find and build secp256k1/CMakeLists.txt
# If that file defines a SHARED library target named 'secp256k1',
# it will produce libsecp256k1.so.
add_subdirectory(secp256k1)
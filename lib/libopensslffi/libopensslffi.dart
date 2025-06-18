// this implementation works with version openssl-3.5.0
// https://github.com/openssl/openssl
import 'dart:ffi' as ffi;
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;

// define classes
final class SHA256_CTX extends ffi.Struct {
  @ffi.Array.multi([8])
  external ffi.Array<ffi.Uint32> h;

  @ffi.Uint32()
  external int Nl;

  @ffi.Uint32()
  external int Nh;

  @ffi.Array.multi([16])
  external ffi.Array<ffi.Uint32> data;

  @ffi.Uint32()
  external int num;

  @ffi.Uint32()
  external int md_len;
}

final class EVP_MD extends ffi.Opaque {}

// SHA256
typedef SHA256C =
    ffi.Pointer<ffi.Uint8> Function(
      ffi.Pointer<ffi.Uint8> d,
      ffi.Int32 n,
      ffi.Pointer<ffi.Uint8> md,
    );
typedef SHA256Dart =
    ffi.Pointer<ffi.Uint8> Function(
      ffi.Pointer<ffi.Uint8> d,
      int n,
      ffi.Pointer<ffi.Uint8> md,
    );

// int SHA256_Init(SHA256_CTX *c);
typedef SHA256_InitC = ffi.Int32 Function(ffi.Pointer<SHA256_CTX> c);
typedef SHA256_InitDart = int Function(ffi.Pointer<SHA256_CTX> contextPtr);

// int SHA256_Update(SHA256_CTX *c, const void *data, size_t len);
typedef SHA256_UpdateC =
    ffi.Int32 Function(
      ffi.Pointer<SHA256_CTX> c,
      ffi.Pointer<ffi.Uint8> data,
      ffi.Size len,
    );
typedef SHA256_UpdateDart =
    int Function(
      ffi.Pointer<SHA256_CTX> contextPtr,
      ffi.Pointer<ffi.Uint8> dataPtr,
      int dataLength,
    );

// int SHA256_Final(unsigned char *md, SHA256_CTX *c);
typedef SHA256_FinalC =
    ffi.Int32 Function(ffi.Pointer<ffi.Uint8> md, ffi.Pointer<SHA256_CTX> c);
typedef SHA256_FinalDart =
    int Function(
      ffi.Pointer<ffi.Uint8> outputBufferPtr,
      ffi.Pointer<SHA256_CTX> contextPtr,
    );

// const EVP_MD *EVP_sha512(void);
typedef EVP_sha512C = ffi.Pointer<EVP_MD> Function();
typedef EVP_sha512Dart = ffi.Pointer<EVP_MD> Function();

// unsigned char *HMAC(const EVP_MD *evp_md, const void *key, int key_len,
//      const unsigned char *d, int n, unsigned char *md,
//      unsigned int *md_len);
typedef HMACC =
    ffi.Pointer<ffi.Uint8> Function(
      ffi.Pointer<EVP_MD> evp_md,
      ffi.Pointer<ffi.Uint8> key,
      ffi.Int32 key_len,
      ffi.Pointer<ffi.Uint8> d,
      ffi.Int32 n,
      ffi.Pointer<ffi.Uint8> md,
      ffi.Pointer<ffi.Uint32> md_len,
    );
typedef HMACDart =
    ffi.Pointer<ffi.Uint8> Function(
      ffi.Pointer<EVP_MD> evp_md,
      ffi.Pointer<ffi.Uint8> key,
      int key_len,
      ffi.Pointer<ffi.Uint8> d,
      int n,
      ffi.Pointer<ffi.Uint8> md,
      ffi.Pointer<ffi.Uint32> md_len,
    );

// int PKCS5_PBKDF2_HMAC(const char *pass, int passlen,
//                       const unsigned char *salt, int saltlen, int iter,
//                       const EVP_MD *digest, int keylen, unsigned char *out);
typedef PKCS5_PBKDF2_HMACC =
    ffi.Int32 Function(
      ffi.Pointer<Utf8> pass,
      ffi.Int32 passlen,
      ffi.Pointer<ffi.Uint8> salt,
      ffi.Int32 saltlen,
      ffi.Int32 iter,
      ffi.Pointer<EVP_MD> digest,
      ffi.Int32 keylen,
      ffi.Pointer<ffi.Uint8> out,
    );
typedef PKCS5_PBKDF2_HMACDart =
    int Function(
      ffi.Pointer<Utf8> pass,
      int passlen,
      ffi.Pointer<ffi.Uint8> salt,
      int saltlen,
      int iter,
      ffi.Pointer<EVP_MD> digest,
      int keylen,
      ffi.Pointer<ffi.Uint8> out,
    );

class LibOpenSSLFFI {
  static const int sha256DigestLength = 32;
  static const int sha512DigestLength = 64;

  static ffi.DynamicLibrary? _lib;
  static bool _isInitialized = false;
  static bool _warningPrinted = false;

  // Static FFI function pointers
  //
  /// A Dart function signature for calling the native OpenSSL SHA256 function.
  ///
  /// - [dataPtr]: A pointer to the input data to be hashed.
  /// - [dataLength]: The length of the input data in bytes.
  /// - [outputBufferPtr]: A pointer to a 32-byte buffer where the hash result will be written.
  ///
  /// Returns a pointer to the [outputBufferPtr] on success, or a NULL pointer on failure.
  static SHA256Dart? _SHA256;
  // static ffi.Pointer<ffi.Uint8> _SHA256(ffi.Pointer<ffi.Uint8> d, int n, ffi.Pointer<ffi.Uint8> md) {
  //   return _SHA256Dart!(d,n,md);
  // }

  /// Dart signature for calling SHA256_Init.
  ///
  /// Initializes the SHA256 context structure.
  /// - [contextPtr]: A pointer to the SHA256_CTX struct to be initialized.
  ///
  /// Returns 1 on success, 0 on error.
  static SHA256_InitDart? _SHA256_Init;

  /// Dart signature for calling SHA256_Update.
  ///
  /// Feeds a chunk of data into the ongoing hash calculation.
  /// - [contextPtr]: The pointer to the SHA256_CTX struct.
  /// - [dataPtr]: A pointer to the chunk of input data.
  /// - [dataLength]: The length of the data chunk in bytes.
  ///
  /// Returns 1 on success, 0 on error.
  static SHA256_UpdateDart? _SHA256_Update;

  /// Dart signature for calling SHA256_Final.
  ///
  /// Finalizes the hash calculation and retrieves the digest.
  /// - [outputBufferPtr]: A pointer to a 32-byte buffer where the hash result will be written.
  /// - [contextPtr]: The pointer to the SHA256_CTX struct.
  ///
  /// Returns 1 on success, 0 on error.
  static SHA256_FinalDart? _SHA256_Final;

  static EVP_sha512Dart? _EVP_sha512;

  static HMACDart? _HMAC;

  static PKCS5_PBKDF2_HMACDart? _PKCS5_PBKDF2_HMAC;

  // Private constructor to prevent instantiation as it's all static
  LibOpenSSLFFI._();

  static bool loaded() {
    return _isInitialized;
  }

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      print("LibOpenSSL: Attempting to initialize FFI...");
      if (Platform.isAndroid) {
        _lib = ffi.DynamicLibrary.open('libcrypto.so');
        // _lib = ffi.DynamicLibrary.open('libcrypto_bundle.so');
      } else if (Platform.isIOS) {
        _lib = ffi.DynamicLibrary.process();
      } else {
        print('LibOpenSSL: Unsupported platform for FFI');
        return;
      }
      print("LibOpenSSL: Native library loaded.");

      // Lookup functions
      _SHA256 =
          _lib!
              .lookup<ffi.NativeFunction<SHA256C>>('SHA256')
              .asFunction<SHA256Dart>();
      _SHA256_Init =
          _lib!
              .lookup<ffi.NativeFunction<SHA256_InitC>>('SHA256_Init')
              .asFunction<SHA256_InitDart>();
      _SHA256_Update =
          _lib!
              .lookup<ffi.NativeFunction<SHA256_UpdateC>>('SHA256_Update')
              .asFunction<SHA256_UpdateDart>();
      _SHA256_Final =
          _lib!
              .lookup<ffi.NativeFunction<SHA256_FinalC>>('SHA256_Final')
              .asFunction<SHA256_FinalDart>();
      _EVP_sha512 =
          _lib!
              .lookup<ffi.NativeFunction<EVP_sha512C>>('EVP_sha512')
              .asFunction<EVP_sha512Dart>();
      _HMAC =
          _lib!
              .lookup<ffi.NativeFunction<HMACC>>('HMAC')
              .asFunction<HMACDart>();
      _PKCS5_PBKDF2_HMAC =
          _lib!
              .lookup<ffi.NativeFunction<PKCS5_PBKDF2_HMACC>>(
                'PKCS5_PBKDF2_HMAC',
              )
              .asFunction<PKCS5_PBKDF2_HMACDart>();
      print("LibOpenSSL: Core cryptographic functions looked up.");

      _isInitialized = true;
      print("LibOpenSSL: FFI initialized successfully.");
    } catch (e, s) {
      print("LibOpenSSL: FFI initialization FAILED: $e\n$s");
      _isInitialized = false;
      _lib = null;
    }
  }

  static void dispose() {
    _lib = null;
    _isInitialized = false;
    _warningPrinted = false;
    print("LibSecp256k1: Disposed.");
  }

  /// Computes the SHA256 hash of the given [data].
  ///
  /// Falls back to a pure Dart implementation if the native library is not initialized.
  static Uint8List? SHA256({required Uint8List data}) {
    // Fallback if FFI is not available.
    if (!_isInitialized || _SHA256 == null) {
      _maybePrintFallbackWarning();
      return _pureDart_sha256(data);
    }

    // The OpenSSL SHA256 function does not have input length restrictions.

    // Use an Arena for managing temporary native memory.
    final arena = Arena();
    try {
      // Allocate native memory for the input data.
      final ffi.Pointer<ffi.Uint8> inputPtr = arena.allocate<ffi.Uint8>(
        data.length,
      );

      // Allocate native memory for the 32-byte output hash.
      final ffi.Pointer<ffi.Uint8> outputPtr = arena.allocate<ffi.Uint8>(
        sha256DigestLength, // Assumes: static const int sha256DigestLength = 32;
      );

      // Copy the input data to the native memory buffer.
      inputPtr.asTypedList(data.length).setAll(0, data);

      // Call the native function.
      // It returns a pointer to the output buffer on success, or NULL on failure.
      final ffi.Pointer<ffi.Uint8> resultPtr = _SHA256!(
        inputPtr,
        data.length,
        outputPtr,
      );

      // Check if the call was successful. A NULL pointer indicates failure.
      if (resultPtr != ffi.nullptr) {
        return _returnUint8List(outputPtr, sha256DigestLength);
      } else {
        // This is a rare failure case for the SHA256 function.
        print("FFI: SHA256 function call failed.");
        return null;
      }
    } finally {
      // Release all memory allocated by the arena in this scope.
      arena.releaseAll();
    }
  }

  /// Computes the double-SHA256 hash (SHA256(SHA256(data))) of the given [data].
  ///
  /// This version is optimized to reduce memory allocations.
  /// Falls back to a pure Dart implementation if the native library is not initialized.
  static Uint8List? doubleSHA256({required Uint8List data}) {
    // Fallback if FFI is not available.
    if (!_isInitialized || _SHA256 == null) {
      _maybePrintFallbackWarning();
      return _pureDart_sha256(_pureDart_sha256(data));
    }

    final arena = Arena();
    try {
      // --- First Hash Operation ---

      // Allocate native memory for the initial input data.
      final ffi.Pointer<ffi.Uint8> inputPtr = arena.allocate<ffi.Uint8>(
        data.length,
      );
      inputPtr.asTypedList(data.length).setAll(0, data);

      // Allocate native memory for the intermediate hash result.
      // This buffer will be reused for the final output.
      final ffi.Pointer<ffi.Uint8> intermediateHashPtr = arena
          .allocate<ffi.Uint8>(sha256DigestLength);

      // Call the native function for the first hash.
      ffi.Pointer<ffi.Uint8> resultPtr = _SHA256!(
        inputPtr,
        data.length,
        intermediateHashPtr,
      );

      if (resultPtr == ffi.nullptr) {
        print("FFI: doubleSHA256 failed on the first hash operation.");
        return null;
      }

      final ffi.Pointer<ffi.Uint8> outputPtr = arena.allocate<ffi.Uint8>(
        sha256DigestLength,
      );

      resultPtr = _SHA256!(
        intermediateHashPtr, // Input is the first hash
        sha256DigestLength, // Input length is always 32
        outputPtr, // Output is the SAME buffer
      );

      if (resultPtr != ffi.nullptr) {
        return _returnUint8List(outputPtr, sha256DigestLength);
      } else {
        print("FFI: doubleSHA256 failed on the second hash operation.");
        return null;
      }
    } finally {
      arena.releaseAll();
    }
  }

  /// Computes a single SHA256 hash from a list of data chunks.
  ///
  /// This function processes the data incrementally, making it efficient for
  /// hashing multiple buffers or streams without holding all data in memory at once.
  /// Falls back to a pure Dart implementation if the native library is not initialized.
  static Uint8List? incrementalSHA256({required List<Uint8List> data}) {
    // Fallback if FFI is not available.
    if (!_isInitialized ||
        _SHA256_Init == null ||
        _SHA256_Update == null ||
        _SHA256_Final == null) {
      _maybePrintFallbackWarning();
      return _pureDart_incrementalSHA256(data);
    }

    // Use an Arena for managing all temporary native memory.
    final arena = Arena();
    try {
      final int totalLength = data.fold(
        0,
        (previousValue, list) => previousValue + list.length,
      );
      final ffi.Pointer<ffi.Uint8> dataPtr = arena.allocate(totalLength);
      final bufferView = dataPtr.asTypedList(totalLength);
      int index = 0;
      for (final chunk in data) {
        bufferView.setAll(index, chunk);
        index += chunk.length;
      }

      final ffi.Pointer<ffi.Uint8> outputPtr = arena.allocate(
        sha256DigestLength,
      );
      ffi.Pointer<ffi.Uint8> resultPtr = _SHA256!(
        dataPtr,
        totalLength,
        outputPtr,
      );

      if (resultPtr != ffi.nullptr) {
        return _returnUint8List(outputPtr, sha256DigestLength);
      } else {
        print("FFI: SHA256 function call failed.");
        return null;
      }
    } finally {
      // Release all memory allocated by the arena.
      arena.releaseAll();
    }
  }

  /// Computes a tagged hash according to Bitcoin's BIP-340 specification.
  ///
  /// The algorithm is `SHA256(SHA256(tag) || SHA256(tag) || data)`.
  /// This is used for creating unique hash contexts for different purposes.
  /// Falls back to a pure Dart implementation if the native library is not initialized.
  static Uint8List? taggedHashSHA256({
    required Uint8List tag,
    required Uint8List data,
  }) {
    // Fallback if FFI is not available. Check all required functions.
    if (!_isInitialized ||
        _SHA256 == null || // For the initial tag hash
        _SHA256_Init == null ||
        _SHA256_Update == null ||
        _SHA256_Final == null) {
      _maybePrintFallbackWarning();
      return _pureDart_taggedHashSHA256(tag, data);
    }

    // Use an Arena for managing all temporary native memory.
    final arena = Arena();
    try {
      // --- Step 1: Compute SHA256(tag) ---
      final ffi.Pointer<ffi.Uint8> tagPtr = arena.allocate(tag.length);
      tagPtr.asTypedList(tag.length).setAll(0, tag);

      final ffi.Pointer<ffi.Uint8> tagHashPtr = arena.allocate(
        sha256DigestLength,
      );
      final ffi.Pointer<ffi.Uint8> tagHashResultPtr = _SHA256!(
        tagPtr,
        tag.length,
        tagHashPtr,
      );

      if (tagHashResultPtr == ffi.nullptr) {
        print(
          "FFI: taggedHashSHA256 failed on the initial tag hash operation.",
        );
        return null;
      }
      // The result of SHA256(tag) is now in tagHashPtr.

      // --- Step 2: Compute the final incremental hash ---
      final ffi.Pointer<SHA256_CTX> contextPtr = arena.allocate(
        ffi.sizeOf<SHA256_CTX>(),
      );

      if (_SHA256_Init!(contextPtr) != 1) {
        print("FFI: taggedHashSHA256 failed on SHA256_Init.");
        return null;
      }

      // Update with the tag hash twice
      if (_SHA256_Update!(contextPtr, tagHashPtr, sha256DigestLength) != 1) {
        print("FFI: taggedHashSHA256 failed on the first tag hash update.");
        return null;
      }
      if (_SHA256_Update!(contextPtr, tagHashPtr, sha256DigestLength) != 1) {
        print("FFI: taggedHashSHA256 failed on the second tag hash update.");
        return null;
      }

      // Update with the main data
      final ffi.Pointer<ffi.Uint8> dataPtr = arena.allocate(data.length);
      dataPtr.asTypedList(data.length).setAll(0, data);
      if (_SHA256_Update!(contextPtr, dataPtr, data.length) != 1) {
        print("FFI: taggedHashSHA256 failed on the main data update.");
        return null;
      }

      // Finalize the hash
      final ffi.Pointer<ffi.Uint8> finalOutputPtr = arena.allocate(
        sha256DigestLength,
      );
      if (_SHA256_Final!(finalOutputPtr, contextPtr) != 1) {
        print("FFI: taggedHashSHA256 failed on SHA256_Final.");
        return null;
      }

      // If successful, copy the result to a Dart list and return.
      return _returnUint8List(finalOutputPtr, sha256DigestLength);
    } finally {
      // Release all memory allocated by the arena.
      arena.releaseAll();
    }
  }

  static Uint8List? HMACSHA512({
    required Uint8List secretKey,
    required Uint8List data,
  }) {
    if (!_isInitialized || _HMAC == null || _EVP_sha512 == null) {
      _maybePrintFallbackWarning();
      print("FFI: HMAC-SHA512 dependencies not initialized.");
      return _pureDart_HMACSHA512(secretKey, data);
    }
    // Use an Arena for managing temporary native memory.
    final arena = Arena();
    try {
      final ffi.Pointer<EVP_MD> evpMdPtr = _EVP_sha512!();

      if (evpMdPtr == ffi.nullptr) {
        print("FFI: EVP_sha512() returned a NULL pointer.");
        return null;
      }

      final ffi.Pointer<ffi.Uint8> keyPtr = arena.allocate<ffi.Uint8>(
        secretKey.length,
      );
      final ffi.Pointer<ffi.Uint8> dataPtr = arena.allocate<ffi.Uint8>(
        data.length,
      );
      final ffi.Pointer<ffi.Uint8> digestPtr = arena.allocate<ffi.Uint8>(
        sha512DigestLength,
      );
      final ffi.Pointer<ffi.Uint32> digestLenPtr = arena.allocate<ffi.Uint32>(
        1,
      );

      keyPtr.asTypedList(secretKey.length).setAll(0, secretKey);
      dataPtr.asTypedList(data.length).setAll(0, data);

      final ffi.Pointer<ffi.Uint8> resultPtr = _HMAC!(
        evpMdPtr,
        keyPtr,
        secretKey.length,
        dataPtr,
        data.length,
        digestPtr,
        digestLenPtr,
      );

      if (resultPtr != ffi.nullptr) {
        final int outputLength = digestLenPtr.value;

        if (outputLength > sha512DigestLength) {
          print(
            "FFI Error: HMAC output length ($outputLength) exceeded allocated buffer size ($sha512DigestLength).",
          );
          return null;
        }

        return _returnUint8List(digestPtr, outputLength);
      } else {
        // This indicates a failure within the OpenSSL HMAC function.
        print("FFI: HMAC function call failed and returned NULL.");
        return null;
      }
    } finally {
      // Release all memory allocated by the arena in this scope.
      arena.releaseAll();
    }
  }

  static Future<Uint8List?> PBKDF2_SHA512({
    required String password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  }) async {
    // Fallback if FFI dependencies are not properly initialized.
    if (!_isInitialized || _PKCS5_PBKDF2_HMAC == null || _EVP_sha512 == null) {
      _maybePrintFallbackWarning();
      print("FFI: PBKDF2-SHA512 dependencies not initialized.");
      return _pureDart_PBKDF2_SHA512(password:password, salt:salt, iterations:iterations, keyLength:keyLength);
    }

    // Use an Arena for managing temporary native memory.
    final arena = Arena();
    try {
      // 1. Get the digest algorithm pointer from OpenSSL.
      final ffi.Pointer<EVP_MD> evpMdPtr = _EVP_sha512!();
      if (evpMdPtr == ffi.nullptr) {
        print("FFI: EVP_sha512() returned a NULL pointer.");
        return null;
      }

      // 2. Allocate native memory for the password, salt, and output key.
      // The password string is converted to a null-terminated UTF8 C-string.
      final ffi.Pointer<Utf8> passwordPtr = password.toNativeUtf8(
        allocator: arena,
      );
      final ffi.Pointer<ffi.Uint8> saltPtr = arena.allocate<ffi.Uint8>(
        salt.length,
      );

      // The output buffer for the derived key.
      final ffi.Pointer<ffi.Uint8> outPtr = arena.allocate<ffi.Uint8>(
        keyLength,
      );

      // 3. Copy the salt data to its native memory buffer.
      saltPtr.asTypedList(salt.length).setAll(0, salt);

      // 4. Call the native PKCS5_PBKDF2_HMAC function.
      // It returns 1 on success and 0 on failure.
      final int result = _PKCS5_PBKDF2_HMAC!(
        passwordPtr,
        password.length, // Note: Using string length, not Utf8 byte length
        saltPtr,
        salt.length,
        iterations,
        evpMdPtr,
        keyLength,
        outPtr,
      );

      // 5. Check if the call was successful.
      if (result == 1) {
        // If successful, outPtr now holds the derived key.
        // We use your existing helper to safely copy it into a Dart list.
        return _returnUint8List(outPtr, keyLength);
      } else {
        // This indicates a failure within the OpenSSL PBKDF2 function.
        print("FFI: PKCS5_PBKDF2_HMAC function call failed and returned 0.");
        return null;
      }
    } finally {
      // Release all memory allocated by the arena in this scope.
      arena.releaseAll();
    }
  }

  // pure Dart functions
  static Uint8List _pureDart_sha256(Uint8List data) {
    return _ensureUint8List(crypto.sha256.convert(data).bytes);
  }

  static Uint8List _pureDart_incrementalSHA256(List<Uint8List> data) {
    final sha256Hasher = cryptography.Sha256().toSync().newHashSink();
    for (final chunk in data) {
      sha256Hasher.add(chunk);
    }

    sha256Hasher.close();
    return _ensureUint8List(sha256Hasher.hashSync().bytes);
  }

  static Uint8List _pureDart_taggedHashSHA256(Uint8List tag, Uint8List data) {
    var tagHash = sha256.convert(tag).bytes;
    return Uint8List.fromList(
      sha256.convert([...tagHash, ...tagHash, ...data]).bytes,
    );
  }

  static Uint8List _pureDart_HMACSHA512(Uint8List secretKey, Uint8List data) {
    final hmacSha512 = cryptography.Hmac(cryptography.Sha512());
    final secretKeyObj = cryptography.SecretKeyData(secretKey);
    final mac = hmacSha512.toSync().calculateMacSync(
      data,
      secretKeyData: secretKeyObj,
      nonce: <int>[],
    );
    return _ensureUint8List(mac.bytes);
  }

  static Future<Uint8List> _pureDart_PBKDF2_SHA512({
    required String password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  }) async {
    var pb = cryptography.Pbkdf2(
      macAlgorithm: cryptography.Hmac(cryptography.Sha512()),
      iterations: 2048,
      bits: 64 * 8,
    ).toSync();
    final pass = await pb.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return _ensureUint8List(await pass.extractBytes());
  }

  // Helper functions
  static void _maybePrintFallbackWarning() {
    if (!_warningPrinted) {
      print(
        "WARNING: LibSecp256k1 FFI not available or failed to initialize. Using Dart fallback implementations (NOT OPTIMIZED). _isInitialized=${_isInitialized} _lib=${_lib}",
      );
      _warningPrinted = true;
    }
  }

  static Uint8List _ensureUint8List(List<int> bytesList) {
    if (bytesList is Uint8List) {
      return bytesList;
    }
    return Uint8List.fromList(bytesList);
  }

  static Uint8List _returnUint8List(
    ffi.Pointer<ffi.Uint8> pointer,
    int length,
  ) {
    return Uint8List.fromList(pointer.asTypedList(length).clone());
  }
}

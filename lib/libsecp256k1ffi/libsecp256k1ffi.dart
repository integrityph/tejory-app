import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:blockchain_utils/crypto/crypto/cdsa/secp256k1/secp256k1.dart';
import 'package:ffi/ffi.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:elliptic/src/elliptic.dart';
import 'package:elliptic/src/base.dart';
import 'package:elliptic/src/publickey.dart';

// classes
final class Secp256k1Context extends ffi.Opaque {}

final class Secp256k1PubkeyStruct extends ffi.Opaque {}

final class Secp256k1EcdsaSignatureStruct extends ffi.Struct {
  @ffi.Array(64) // secp256k1_ecdsa_signature is typically 64 bytes
  external ffi.Array<ffi.Uint8> data;
}

typedef CreateContextC =
    ffi.Pointer<Secp256k1Context> Function(ffi.Uint32 flags);
typedef CreateContextDart = ffi.Pointer<Secp256k1Context> Function(int flags);

typedef DestroyContextC = ffi.Void Function(ffi.Pointer<Secp256k1Context> ctx);
typedef DestroyContextDart = void Function(ffi.Pointer<Secp256k1Context> ctx);

typedef PubkeyCreateC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1PubkeyStruct>
      pubkeyOutput, // Pointer to the pubkey struct to be filled
      ffi.Pointer<ffi.Uint8> seckeyInput, // Pointer to the 32-byte secret key
    );
typedef PubkeyCreateDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1PubkeyStruct> pubkeyOutput,
      ffi.Pointer<ffi.Uint8> seckeyInput,
    );

typedef PubkeySerializeC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<ffi.Uint8>
      serializedOutput, // Buffer for serialized key (33 or 65 bytes)
      ffi.Pointer<ffi.Size>
      outputLenInOut, // In: size of output buffer. Out: actual size written.
      // ffi.Size maps to size_t in C.
      ffi.Pointer<Secp256k1PubkeyStruct>
      pubkeyInput, // Pointer to the internal pubkey struct
      ffi.Uint32 flags, // e.g., SECP256K1_EC_COMPRESSED
    );
typedef PubkeySerializeDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<ffi.Uint8> serializedOutput,
      ffi.Pointer<ffi.Size> outputLenInOut,
      ffi.Pointer<Secp256k1PubkeyStruct> pubkeyInput,
      int flags, // Dart int can map to C unsigned int if values are compatible
    );

typedef PrivkeyTweakAddC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<ffi.Uint8> seckey,
      ffi.Pointer<ffi.Uint8> tweak,
    );
typedef PrivkeyTweakAddDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<ffi.Uint8> seckey,
      ffi.Pointer<ffi.Uint8> tweak,
    );

// secp256k1_ec_pubkey_parse
typedef PubkeyParseC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1PubkeyStruct> pubkey,
      ffi.Pointer<ffi.Uint8> input,
      ffi.Size inputlen,
    );
typedef PubkeyParseDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1PubkeyStruct> pubkey,
      ffi.Pointer<ffi.Uint8> input,
      int inputlen,
    );

// secp256k1_ec_pubkey_tweak_add
typedef PubkeyTweakAddC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1PubkeyStruct> pubkey, // In/Out
      ffi.Pointer<ffi.Uint8> tweak,
    );
typedef PubkeyTweakAddDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1PubkeyStruct> pubkey,
      ffi.Pointer<ffi.Uint8> tweak,
    );

// secp256k1_ec_pubkey_combine
typedef PubkeyCombineC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1PubkeyStruct> output,
      ffi.Pointer<ffi.Pointer<Secp256k1PubkeyStruct>> ins,
      ffi.Size n,
    );
typedef PubkeyCombineDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1PubkeyStruct> output,
      ffi.Pointer<ffi.Pointer<Secp256k1PubkeyStruct>> ins,
      int n,
    );

// Define the nonce function signature for secp256k1_ecdsa_sign
// This matches the C signature:
// int (*secp256k1_nonce_function)(unsigned char *nonce32, const unsigned char *msg32, const unsigned char *key32, const unsigned char *algo, void *data, unsigned int counter)
typedef Secp256k1NonceFunctionC =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8> nonce32,
      ffi.Pointer<ffi.Uint8> msg32,
      ffi.Pointer<ffi.Uint8> key32,
      ffi.Pointer<ffi.Uint8> algo,
      ffi.Pointer<ffi.Void> data,
      ffi.Uint32 counter,
    );
typedef Secp256k1NonceFunctionDart =
    int Function(
      ffi.Pointer<ffi.Uint8> nonce32,
      ffi.Pointer<ffi.Uint8> msg32,
      ffi.Pointer<ffi.Uint8> key32,
      ffi.Pointer<ffi.Uint8> algo,
      ffi.Pointer<ffi.Void> data,
      int counter,
    );

// secp256k1_ecdsa_sign
typedef EcdsaSignC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
      ffi.Pointer<ffi.Uint8> msg32, // 32-byte message hash
      ffi.Pointer<ffi.Uint8> seckey, // 32-byte secret key
      ffi.Pointer<ffi.NativeFunction<Secp256k1NonceFunctionC>>
      noncefp, // Can be ffi.Null.toPointer() for default
      ffi.Pointer<ffi.Void> noncefp_data, // Can be ffi.Null.toPointer()
    );
typedef EcdsaSignDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
      ffi.Pointer<ffi.Uint8> msg32,
      ffi.Pointer<ffi.Uint8> seckey,
      ffi.Pointer<ffi.NativeFunction<Secp256k1NonceFunctionC>> noncefp,
      ffi.Pointer<ffi.Void> noncefp_data,
    );

// secp256k1_ecdsa_signature_serialize_der
typedef EcdsaSignatureSerializeDerC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<ffi.Uint8> output,
      ffi.Pointer<ffi.Size> outputlen, // Pointer to size_t to get output length
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
    );
typedef EcdsaSignatureSerializeDerDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<ffi.Uint8> output,
      ffi.Pointer<ffi.Size> outputlen,
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
    );

// secp256k1_ecdsa_signature_serialize_compact
typedef EcdsaSignatureSerializeCompactC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<ffi.Uint8> output64, // 64-byte output buffer
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
    );
typedef EcdsaSignatureSerializeCompactDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<ffi.Uint8> output64,
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
    );

// secp256k1_ecdsa_verify
typedef EcdsaVerifyC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
      ffi.Pointer<ffi.Uint8> msg32, // 32-byte message hash
      ffi.Pointer<Secp256k1PubkeyStruct> pubkey,
    );
typedef EcdsaVerifyDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
      ffi.Pointer<ffi.Uint8> msg32,
      ffi.Pointer<Secp256k1PubkeyStruct> pubkey,
    );

// secp256k1_ecdsa_signature_parse_der
typedef EcdsaSignatureParseDerC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
      ffi.Pointer<ffi.Uint8> input,
      ffi.Size inputlen,
    );
typedef EcdsaSignatureParseDerDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
      ffi.Pointer<ffi.Uint8> input,
      int inputlen,
    );

// secp256k1_ecdsa_signature_parse_compact
typedef EcdsaSignatureParseCompactC =
    ffi.Int32 Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
      ffi.Pointer<ffi.Uint8> input64, // 64-byte input buffer
    );
typedef EcdsaSignatureParseCompactDart =
    int Function(
      ffi.Pointer<Secp256k1Context> ctx,
      ffi.Pointer<Secp256k1EcdsaSignatureStruct> sig,
      ffi.Pointer<ffi.Uint8> input64,
    );

// this implementation works with version v0.6.0
// https://github.com/bitcoin-core/secp256k1
class LibSecp256k1FFI {
  static const int _SECP256K1_CONTEXT_SIGN = 0x0201;
  static const int _SECP256K1_CONTEXT_VERIFY = 0x0101;
  static const int _SECP256K1_EC_COMPRESSED_FLAG = 258;
  static const int _SECP256K1_EC_UNCOMPRESSED_FLAG = 2;

  static ffi.DynamicLibrary? _lib;
  static ffi.Pointer<Secp256k1Context>? _context;
  static bool _isInitialized = false;
  static bool _warningPrinted = false;

  // Static FFI function pointers
  static CreateContextDart? _createContext;
  static DestroyContextDart? _destroyContext;
  static PrivkeyTweakAddDart? _privkeyTweakAdd;
  static PubkeySerializeDart? _pubkeySerialize;
  static PubkeyCreateDart? _pubkeyCreate;
  static PubkeyParseDart? _pubkeyParse;
  static PubkeyTweakAddDart? _pubkeyTweakAdd;
  static PubkeyCombineDart? _pubkeyCombine;
  static Secp256k1NonceFunctionDart? _secp256k1NonceFunctionDart;
  static EcdsaSignDart? _ecdsaSignDart;
  static EcdsaSignatureSerializeDerDart? _ecdsaSignatureSerializeDerDart;
  static EcdsaSignatureSerializeCompactDart? _ecdsaSignatureSerializeCompactDart;
  static EcdsaVerifyDart? _ecdsaVerifyDart;
  static EcdsaSignatureParseDerDart? _ecdsaSignatureParseDerDart;
  static EcdsaSignatureParseCompactDart? _ecdsaSignatureParseCompactDart;

  // Private constructor to prevent instantiation as it's all static
  LibSecp256k1FFI._();

  static bool loaded() {
    return _isInitialized;
  }

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      print("LibSecp256k1: Attempting to initialize FFI...");
      if (Platform.isAndroid) {
        _lib = ffi.DynamicLibrary.open('libsecp256k1.so');
        // _lib = ffi.DynamicLibrary.open('libcrypto_bundle.so');
      } else if (Platform.isIOS) {
        _lib = ffi.DynamicLibrary.process();
      } else {
        print('LibSecp256k1: Unsupported platform for FFI');
        return;
      }
      print("LibSecp256k1: Native library loaded.");

      // Lookup essential context functions
      _createContext =
          _lib!
              .lookup<ffi.NativeFunction<CreateContextC>>(
                'secp256k1_context_create',
              )
              .asFunction<CreateContextDart>();
      _destroyContext =
          _lib!
              .lookup<ffi.NativeFunction<DestroyContextC>>(
                'secp256k1_context_destroy',
              )
              .asFunction<DestroyContextDart>();
      print("LibSecp256k1: Context functions looked up.");

      _context = _createContext!(
        _SECP256K1_CONTEXT_SIGN | _SECP256K1_CONTEXT_VERIFY,
      );
      if (_context == ffi.nullptr || _context!.address == 0) {
        // Added address check for extra safety
        _context =
            null; // Ensure it's null if creation failed to prevent later misuse
        throw Exception('LibSecp256k1: Failed to create secp256k1 context.');
      }
      print("LibSecp256k1: secp256k1_context created successfully.");

      // Lookup other functions
      _privkeyTweakAdd =
          _lib!
              .lookup<ffi.NativeFunction<PrivkeyTweakAddC>>(
                'secp256k1_ec_seckey_tweak_add',
              )
              .asFunction<PrivkeyTweakAddDart>();
      _pubkeyCreate =
          _lib!
              .lookup<ffi.NativeFunction<PubkeyCreateC>>(
                'secp256k1_ec_pubkey_create',
              )
              .asFunction<PubkeyCreateDart>();
      _pubkeySerialize =
          _lib!
              .lookup<ffi.NativeFunction<PubkeySerializeC>>(
                'secp256k1_ec_pubkey_serialize',
              )
              .asFunction<PubkeySerializeDart>();
      _pubkeyParse =
          _lib!
              .lookup<ffi.NativeFunction<PubkeyParseC>>(
                'secp256k1_ec_pubkey_parse',
              )
              .asFunction<PubkeyParseDart>();
      _pubkeyTweakAdd =
          _lib!
              .lookup<ffi.NativeFunction<PubkeyTweakAddC>>(
                'secp256k1_ec_pubkey_tweak_add',
              )
              .asFunction<PubkeyTweakAddDart>();
      _pubkeyCombine =
          _lib!
              .lookup<ffi.NativeFunction<PubkeyCombineC>>(
                'secp256k1_ec_pubkey_combine',
              )
              .asFunction<PubkeyCombineDart>();
      _ecdsaSignDart =
          _lib!
              .lookup<ffi.NativeFunction<EcdsaSignC>>('secp256k1_ecdsa_sign')
              .asFunction<EcdsaSignDart>();
      _ecdsaSignatureSerializeDerDart =
          _lib!
              .lookup<ffi.NativeFunction<EcdsaSignatureSerializeDerC>>('secp256k1_ecdsa_signature_serialize_der')
              .asFunction<EcdsaSignatureSerializeDerDart>();
      _ecdsaSignatureSerializeCompactDart =
          _lib!
              .lookup<ffi.NativeFunction<EcdsaSignatureSerializeCompactC>>('secp256k1_ecdsa_signature_serialize_compact')
              .asFunction<EcdsaSignatureSerializeCompactDart>();
      _ecdsaVerifyDart =
          _lib!
              .lookup<ffi.NativeFunction<EcdsaVerifyC>>('secp256k1_ecdsa_verify')
              .asFunction<EcdsaVerifyDart>();
      _ecdsaSignatureParseDerDart =
          _lib!
              .lookup<ffi.NativeFunction<EcdsaSignatureParseDerC>>('secp256k1_ecdsa_signature_parse_der')
              .asFunction<EcdsaSignatureParseDerDart>();
      _ecdsaSignatureParseCompactDart =
          _lib!
              .lookup<ffi.NativeFunction<EcdsaSignatureParseCompactC>>('secp256k1_ecdsa_signature_parse_compact')
              .asFunction<EcdsaSignatureParseCompactDart>();
      print("LibSecp256k1: Core cryptographic functions looked up.");

      _isInitialized = true;
      print("LibSecp256k1: FFI initialized successfully.");
    } catch (e, s) {
      print("LibSecp256k1: FFI initialization FAILED: $e\n$s");
      _isInitialized = false;
      _lib = null;
      _context = null;
      _privkeyTweakAdd = null;
      _pubkeyCreate = null;
      _pubkeySerialize = null;
    }
  }

  static void dispose() {
    if (_context != null &&
        _context != ffi.nullptr &&
        _destroyContext != null) {
      _destroyContext!(_context!);
      print("LibSecp256k1: secp256k1_context destroyed.");
    }
    _context = null;
    _lib = null;
    _isInitialized = false;
    _warningPrinted = false;
    print("LibSecp256k1: Disposed.");
  }

  static void _maybePrintFallbackWarning() {
    if (!_warningPrinted) {
      print(
        "WARNING: LibSecp256k1 FFI not available or failed to initialize. Using Dart fallback implementations (NOT OPTIMIZED). _isInitialized=${_isInitialized} _privkeyTweakAdd=${_privkeyTweakAdd} _context=${_context} _lib=${_lib} _pubkeySerialize=${_pubkeySerialize} _pubkeyCreate=${_pubkeyCreate}",
      );
      _warningPrinted = true;
    }
  }

  // --- Public Static Crypto Methods with Fallback ---
  static BigInt? addScalar({
    required List<int> privKeyBytes,
    required List<int> newScalarBytes,
  }) {
    // fallback if there FFI is not available
    if (!_isInitialized ||
        _privkeyTweakAdd == null ||
        _context == null ||
        _lib == null) {
      _maybePrintFallbackWarning();
      return _pureDart_addScalar(privKeyBytes, newScalarBytes);
    }

    final Uint8List pkBytes = _ensureUint8List(privKeyBytes);
    final Uint8List tweakBytes = _ensureUint8List(newScalarBytes);

    if (pkBytes.length != 32) {
      throw ArgumentError(
        "Private key must be 32 bytes for secp256k1. Got ${pkBytes.length}",
      );
    }
    if (tweakBytes.length != 32) {
      throw ArgumentError(
        "Scalar tweak must be 32 bytes for secp256k1. Got ${tweakBytes.length}",
      );
    }

    // Use an Arena for managing temporary native memory for input/output buffer
    final arena = Arena();
    try {
      // Allocate native memory and copy data to it.
      // seckeyPtr will be modified in place by the C function.
      final ffi.Pointer<ffi.Uint8> seckeyPtr = arena.allocate<ffi.Uint8>(
        pkBytes.length,
      );
      final ffi.Pointer<ffi.Uint8> tweakPtr = arena.allocate<ffi.Uint8>(
        tweakBytes.length,
      );

      // Get a Uint8List view into the allocated native memory to copy data easily
      Uint8List seckeyNativeView = seckeyPtr.asTypedList(pkBytes.length);
      Uint8List tweakNativeView = tweakPtr.asTypedList(tweakBytes.length);

      seckeyNativeView.setAll(0, pkBytes);
      tweakNativeView.setAll(0, tweakBytes);

      // Call the native function
      // 'context' here is the ffi.Pointer<Secp256k1Context> you created with secp256k1_context_create
      final int success = _privkeyTweakAdd!(_context!, seckeyPtr, tweakPtr);

      if (success == 1) {
        // If successful, seckeyPtr now holds the tweaked private key.
        // Read it back into a Dart Uint8List.
        final Uint8List resultBytes = Uint8List.fromList(seckeyNativeView);
        // Convert to BigInt (private keys are typically big-endian integers)
        return _bytesToBigInt(resultBytes, Endian.big);
      } else {
        // The resulting key was invalid (e.g., zero). This is a failure case.
        print(
          "FFI: secp256k1_ec_seckey_tweak_add failed (resulting key was invalid).",
        );
        return null;
      }
    } finally {
      arena.releaseAll(); // Release all memory allocated by this arena
    }
  }

  static Uint8List? derivePublicKey({
    required List<int> privateKeyBytes,
    bool compressed = true,
  }) {
    // fallback if there FFI is not available
    if (!_isInitialized ||
        _pubkeySerialize == null ||
        _pubkeyCreate == null ||
        _context == null ||
        _lib == null) {
      _maybePrintFallbackWarning();
      return _pureDart_derivePublicKey(privateKeyBytes, compressed);
    }

    final Uint8List pkBytes = _ensureUint8List(privateKeyBytes);
    if (pkBytes.length != 32) {
      throw ArgumentError(
        "Private key must be 32 bytes for secp256k1. Got ${pkBytes.length}",
      );
    }

    final arena = Arena();
    try {
      final ffi.Pointer<ffi.Uint8> seckeyPtr = arena.allocate<ffi.Uint8>(
        pkBytes.length,
      );
      seckeyPtr.asTypedList(pkBytes.length).setAll(0, pkBytes);

      final ffi.Pointer<Secp256k1PubkeyStruct> pubkeyInternalStructPtr =
          arena.allocate<ffi.Uint8>(64).cast<Secp256k1PubkeyStruct>();

      final int createSuccess = _pubkeyCreate!(
        _context!,
        pubkeyInternalStructPtr,
        seckeyPtr,
      );

      if (createSuccess != 1) {
        print(
          "FFI Error: secp256k1_ec_pubkey_create failed (private key might be invalid).",
        );
        return null;
      }

      final int outputSizeBytes = compressed ? 33 : 65;
      final ffi.Pointer<ffi.Uint8> serializedPubKeyOutputPtr = arena
          .allocate<ffi.Uint8>(outputSizeBytes);
      final ffi.Pointer<ffi.Size> actualOutputLenPtr = arena.allocate<ffi.Size>(
        1,
      );
      actualOutputLenPtr.value = outputSizeBytes;

      final int serializeSuccess = _pubkeySerialize!(
        _context!,
        serializedPubKeyOutputPtr,
        actualOutputLenPtr,
        pubkeyInternalStructPtr,
        compressed
            ? _SECP256K1_EC_COMPRESSED_FLAG
            : _SECP256K1_EC_UNCOMPRESSED_FLAG,
      );

      if (serializeSuccess == 1) {
        final Uint8List resultBytes = Uint8List.fromList(
          serializedPubKeyOutputPtr.asTypedList(actualOutputLenPtr.value),
        );
        return resultBytes;
      } else {
        print("FFI Error: secp256k1_ec_pubkey_serialize failed.");
        return null;
      }
    } finally {
      arena.releaseAll();
    }
  }

  static List<int>? publicKeyScalarAdd({
    required List<int> parentPubKeyBytes, // e.g., 33 bytes compressed
    required List<int> scalarTweakBytes, // 32 bytes (IL from HMAC)
  }) {
    // fallback if there FFI is not available
    if (!_isInitialized ||
        _pubkeyParse == null ||
        _pubkeyTweakAdd == null ||
        _pubkeySerialize == null ||
        _context == null ||
        _lib == null) {
      _maybePrintFallbackWarning();
      return _pureDart_publicKeyScalarAdd(parentPubKeyBytes, scalarTweakBytes);
    }
    if (scalarTweakBytes.length != 32) {
      throw ArgumentError("Scalar tweak must be 32 bytes.");
    }
    if (parentPubKeyBytes.length != 33 && parentPubKeyBytes.length != 65) {
      throw ArgumentError(
        "Parent public key must be 33 (compressed) or 65 (uncompressed) bytes.",
      );
    }

    final arena = Arena();
    try {
      // 1. Prepare parent public key input
      final ffi.Pointer<ffi.Uint8> parentInputPtr = arena.allocate<ffi.Uint8>(
        parentPubKeyBytes.length,
      );
      parentInputPtr
          .asTypedList(parentPubKeyBytes.length)
          .setAll(0, parentPubKeyBytes);

      // Allocate space for the internal secp256k1_pubkey struct (64 bytes)
      final ffi.Pointer<Secp256k1PubkeyStruct> pubkeyStructPtr =
          arena.allocate<ffi.Uint8>(64).cast<Secp256k1PubkeyStruct>();

      // 2. Parse parent public key bytes into the struct
      int success = _pubkeyParse!(
        _context!,
        pubkeyStructPtr,
        parentInputPtr,
        parentPubKeyBytes.length,
      );
      if (success != 1) {
        print("FFI: secp256k1_ec_pubkey_parse failed for parent public key.");
        return null;
      }

      // 3. Prepare tweak input
      final ffi.Pointer<ffi.Uint8> tweakPtr = arena.allocate<ffi.Uint8>(32);
      tweakPtr.asTypedList(32).setAll(0, scalarTweakBytes);

      // 4. Call secp256k1_ec_pubkey_tweak_add (modifies pubkeyStructPtr in place)
      success = _pubkeyTweakAdd!(_context!, pubkeyStructPtr, tweakPtr);
      if (success != 1) {
        print("FFI: secp256k1_ec_pubkey_tweak_add failed.");
        return null;
      }

      // 5. Serialize the resulting (tweaked) public key
      final int outputSizeBytes = 33; // For compressed public key
      final ffi.Pointer<ffi.Uint8> serializedResultPtr = arena
          .allocate<ffi.Uint8>(outputSizeBytes);
      final ffi.Pointer<ffi.Size> actualOutputLenPtr = arena.allocate<ffi.Size>(
        1,
      );
      actualOutputLenPtr.value = outputSizeBytes;

      success = _pubkeySerialize!(
        _context!,
        serializedResultPtr,
        actualOutputLenPtr,
        pubkeyStructPtr,
        _SECP256K1_EC_COMPRESSED_FLAG,
      );

      if (success == 1) {
        return Uint8List.fromList(
          serializedResultPtr.asTypedList(actualOutputLenPtr.value),
        );
      } else {
        print(
          "FFI: secp256k1_ec_pubkey_serialize failed for child public key.",
        );
        return null;
      }
    } finally {
      arena.releaseAll();
    }
  }

  /// Adds two public keys together using the native library.
  ///
  /// Returns a 33-byte compressed public key, or null on failure.
  static List<int>? pointAdd(List<int> pubkeyBytesA, List<int> pubkeyBytesB) {
    if (!_isInitialized ||
        _pubkeyParse == null ||
        _pubkeyCombine == null ||
        _pubkeySerialize == null ||
        _context == null) {
      _maybePrintFallbackWarning();
      return _pureDart_pointAdd(
        _ensureUint8List(pubkeyBytesA),
        _ensureUint8List(pubkeyBytesB),
      );
    }

    // Validate inputs
    for (var key in [pubkeyBytesA, pubkeyBytesB]) {
      if (key.length != 33 && key.length != 65) {
        throw ArgumentError(
          "Public keys must be 33 (compressed) or 65 (uncompressed) bytes.",
        );
      }
    }

    final arena = Arena();
    try {
      // 1. Parse both public keys into internal structs.
      final ffi.Pointer<Secp256k1PubkeyStruct> pubkeyA =
          arena<ffi.Uint8>(64).cast<Secp256k1PubkeyStruct>();
      final ffi.Pointer<Secp256k1PubkeyStruct> pubkeyB =
          arena<ffi.Uint8>(64).cast<Secp256k1PubkeyStruct>();

      final parseResults = [
        _parseKey(pubkeyBytesA, pubkeyA, arena),
        _parseKey(pubkeyBytesB, pubkeyB, arena),
      ];
      if (parseResults.any((s) => s != 1)) {
        print("FFI: secp256k1_ec_pubkey_parse failed.");
        return null;
      }

      // 2. Prepare the input array of pointers for the combine call.
      final ffi.Pointer<ffi.Pointer<Secp256k1PubkeyStruct>> ins =
          arena<ffi.Pointer<Secp256k1PubkeyStruct>>(2);
      ins[0] = pubkeyA;
      ins[1] = pubkeyB;

      // 3. Call the combine function.
      final ffi.Pointer<Secp256k1PubkeyStruct> combinedPubkey =
          arena<ffi.Uint8>(64).cast<Secp256k1PubkeyStruct>();
      int success = _pubkeyCombine!(_context!, combinedPubkey, ins, 2);
      if (success != 1) {
        print("FFI: secp256k1_ec_pubkey_combine failed.");
        return null;
      }

      // 4. Serialize the resulting combined public key.
      final int outputSizeBytes = 33; // For compressed public key
      final ffi.Pointer<ffi.Uint8> serializedResultPtr = arena<ffi.Uint8>(
        outputSizeBytes,
      );
      final ffi.Pointer<ffi.Size> actualOutputLenPtr = arena<ffi.Size>();
      actualOutputLenPtr.value = outputSizeBytes;

      success = _pubkeySerialize!(
        _context!,
        serializedResultPtr,
        actualOutputLenPtr,
        combinedPubkey,
        _SECP256K1_EC_COMPRESSED_FLAG,
      );

      if (success == 1) {
        return serializedResultPtr
            .asTypedList(actualOutputLenPtr.value)
            .sublist(1);
      } else {
        print("FFI: secp256k1_ec_pubkey_serialize failed for combined key.");
        return null;
      }
    } finally {
      arena.releaseAll();
    }
  }

  // --- Wrapper for secp256k1_ecdsa_sign ---
  /// Signs a 32-byte message hash with the given private key using ECDSA.
  ///
  /// The `message` parameter **must** be the 32-byte hash of the data you want to sign.
  /// If you have a longer message, hash it first using a suitable cryptographic
  /// hashing function (e.g., SHA-256 from `package:crypto`).
  ///
  /// If `messagePrefix` is provided, the message will be preprocessed according
  /// to Bitcoin's signed message standard (e.g., `"\x18Bitcoin Signed Message:\n" + len(message_bytes) + message_bytes`)
  /// before hashing. In this case, `message` should be the *original* message,
  /// and the hashing will be performed internally.
  ///
  /// Returns the DER-encoded ECDSA signature as a [Uint8List], or `null` if signing fails.
  static Uint8List? signMessage(
    Uint8List message,
    Uint8List privateKeyBytes, {
    Uint8List? messagePrefix,
  }) {
    if (!_isInitialized || _ecdsaSignDart == null || _ecdsaSignatureSerializeDerDart == null || _context == null) {
      _maybePrintFallbackWarning();
      print("FFI: Not initialized or required functions missing.");
      return _pureDart_signMessage(message, privateKeyBytes, messagePrefix: messagePrefix);
    }

    // Validate inputs
    if (privateKeyBytes.length != 32) {
      throw ArgumentError("Private key must be 32 bytes.");
    }

    final arena = Arena();
    try {
      final ffi.Pointer<ffi.Uint8> privateKeyPtr = arena<ffi.Uint8>(32);
      privateKeyPtr.asTypedList(32).setAll(0, privateKeyBytes);

      if (messagePrefix != null) {
        if (messagePrefix.length < 1 || messagePrefix[0] != 0x18) {
          throw ArgumentError(
                "`messagePrefix` should start with 0x18"
            );
        }
      } else {
        messagePrefix = _ensureUint8List('\x18Bitcoin Signed Message:\n'.codeUnits);
      }

      final encodeLength = IntUtils.encodeVarint(message.length);
      message = Uint8List.fromList([...messagePrefix, ...encodeLength, ...message]);
      Uint8List messageHash = _ensureUint8List(QuickCrypto.sha256DoubleHash(message));


      final ffi.Pointer<ffi.Uint8> msg32Ptr = arena<ffi.Uint8>(32);
      msg32Ptr.asTypedList(32).setAll(0, messageHash);

      final ffi.Pointer<Secp256k1EcdsaSignatureStruct> sigStructPtr =
          arena<ffi.Uint8>(64).cast<Secp256k1EcdsaSignatureStruct>();

      // 1. Call the signing function
      int success = _ecdsaSignDart!(
        _context!,
        sigStructPtr,
        msg32Ptr,
        privateKeyPtr,
        ffi.nullptr, // Use NULL for default deterministic nonce
        ffi.nullptr, // No data for the nonce function
      );

      if (success != 1) {
        print("FFI: secp256k1_ecdsa_sign failed.");
        return null;
      }

      // 2. Serialize the signature to DER format
      // DER signatures can be up to 72 bytes (plus 9 for headers/lengths) = ~72
      final int maxDerSignatureSize = 72; // Maximum possible DER size
      final ffi.Pointer<ffi.Uint8> derOutputPtr = arena<ffi.Uint8>(maxDerSignatureSize);
      final ffi.Pointer<ffi.Size> derOutputLenPtr = arena<ffi.Size>();
      derOutputLenPtr.value = maxDerSignatureSize; // Initialize with max buffer size

      success = _ecdsaSignatureSerializeDerDart!(
        _context!,
        derOutputPtr,
        derOutputLenPtr,
        sigStructPtr,
      );

      if (success == 1) {
        // Copy the result to a Dart Uint8List
        return derOutputPtr.asTypedList(derOutputLenPtr.value);
      } else {
        print("FFI: secp256k1_ecdsa_signature_serialize_der failed.");
        return null;
      }
    } finally {
      arena.releaseAll();
    }
  }

  static Uint8List _pureDart_signMessage(Uint8List message, Uint8List privateKeyBytes, {Uint8List? messagePrefix}) {
    return Uint8List(0);
  }

  static Uint8List _pureDart_pointAdd(Uint8List A, Uint8List B) {
    EllipticCurve _s256 = EllipticCurve(
      'secp256k1',
      256,
      BigInt.parse(
        'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
        radix: 16,
      ), // p
      BigInt.zero, // a
      BigInt.from(7), // b
      BigInt.zero, // S
      AffinePoint.fromXY(
        BigInt.parse(
          '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
          radix: 16,
        ),
        BigInt.parse(
          '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',
          radix: 16,
        ),
      ), // G
      BigInt.parse(
        'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
        radix: 16,
      ), // n
      01, // h
    );
    var curve = _s256;
    PublicKey a = PublicKey.fromHex(curve, hex.encode(A));
    PublicKey b = PublicKey.fromHex(curve, hex.encode(B));
    var p1 = AffinePoint.fromXY(a.X, a.Y);
    var p2 = AffinePoint.fromXY(b.X, b.Y);

    return Uint8List.fromList(
      hex.decode(curve.add(p1, p2).X.toRadixString(16).padLeft(64)),
    );
  }

  // --- Pure Dart Fallback Implementations (stubs, you'd have your actual logic) ---
  static BigInt? _pureDart_addScalar(
    List<int> privKeyBytes,
    List<int> newScalar,
  ) {
    print("Executing _pureDart_addScalar (fallback)");
    Secp256k1Scalar privKeyScalar = Secp256k1Scalar();
    Secp256k1.secp256k1ScalarSetB32(privKeyScalar, privKeyBytes);
    Secp256k1Scalar newSc = Secp256k1Scalar();
    Secp256k1.secp256k1ScalarSetB32(newSc, newScalar);
    Secp256k1Scalar result = Secp256k1Scalar();
    Secp256k1.secp256k1ScalarAdd(result, privKeyScalar, newSc);
    final scBytes = List<int>.filled(32, 0);
    Secp256k1.secp256k1ScalarGetB32(scBytes, result);
    final nd = BigintUtils.fromBytes(scBytes);

    final ilInt = BigintUtils.fromBytes(newScalar);
    final privKeyInt = BigintUtils.fromBytes(privKeyBytes);
    final generator = EllipticCurveGetter.generatorFromType(
      EllipticCurveTypes.secp256k1,
    );
    final newScalarBig = (ilInt + privKeyInt) % generator.order!;
    assert(newScalarBig == nd);
    return nd;
  }

  static Uint8List? _pureDart_derivePublicKey(
    List<int> privateKeyBytes,
    bool compressed,
  ) {
    print("Executing _pureDart_derivePublicKey (fallback)");
    // Implement your pure Dart public key derivation here
    throw UnimplementedError(
      "Pure Dart derivePublicKey fallback not implemented.",
    );
  }

  static Uint8List _pureDart_publicKeyScalarAdd(
    List<int> parentPubKeyBytes,
    List<int> scalarTweakBytes,
  ) {
    var type = EllipticCurveTypes.secp256k1;
    final generator = EllipticCurveGetter.generatorFromType(type);

    var pubKey = Bip32PublicKey.fromBytes(
      parentPubKeyBytes,
      Bip32KeyData(),
      Bip32KeyNetVersions([0x04, 0x35, 0x87, 0xCF], [0x04, 0x35, 0x83, 0x94]),
      type,
    );

    final newPubKeyPoint =
        pubKey.point + (generator * BigintUtils.fromBytes(scalarTweakBytes));
    return _ensureUint8List(newPubKeyPoint.toBytes());
  }

  // Helper (keep static or move outside if used elsewhere)
  static Uint8List _ensureUint8List(List<int> bytesList) {
    if (bytesList is Uint8List) {
      return bytesList;
    }
    return Uint8List.fromList(bytesList);
  }

  static BigInt _bytesToBigInt(Uint8List bytes, Endian endian) {
    BigInt result = BigInt.zero;
    if (endian == Endian.big) {
      for (int i = 0; i < bytes.length; i++) {
        result = (result << 8) | BigInt.from(bytes[i]);
      }
    } else {
      // Little Endian
      for (int i = bytes.length - 1; i >= 0; i--) {
        result = (result << 8) | BigInt.from(bytes[i]);
      }
    }
    return result;
  }

  static int _parseKey(
    List<int> keyBytes,
    ffi.Pointer<Secp256k1PubkeyStruct> keyStructPtr,
    Arena arena,
  ) {
    final ffi.Pointer<ffi.Uint8> inputPtr = arena<ffi.Uint8>(keyBytes.length);
    inputPtr.asTypedList(keyBytes.length).setAll(0, keyBytes);
    return _pubkeyParse!(_context!, keyStructPtr, inputPtr, keyBytes.length);
  }
}

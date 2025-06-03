import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:blockchain_utils/crypto/crypto/cdsa/secp256k1/secp256k1.dart';
import 'package:ffi/ffi.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

// classes
final class Secp256k1Context extends ffi.Opaque {}
final class Secp256k1PubkeyStruct extends ffi.Opaque {}
// final class Secp256k1InternalPubkey extends ffi.Opaque {}

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
typedef PubkeyParseC = ffi.Int32 Function(
    ffi.Pointer<Secp256k1Context> ctx,
    ffi.Pointer<Secp256k1PubkeyStruct> pubkey,
    ffi.Pointer<ffi.Uint8> input,
    ffi.Size inputlen);
typedef PubkeyParseDart = int Function(
    ffi.Pointer<Secp256k1Context> ctx,
    ffi.Pointer<Secp256k1PubkeyStruct> pubkey,
    ffi.Pointer<ffi.Uint8> input,
    int inputlen);

// secp256k1_ec_pubkey_tweak_add
typedef PubkeyTweakAddC = ffi.Int32 Function(
    ffi.Pointer<Secp256k1Context> ctx,
    ffi.Pointer<Secp256k1PubkeyStruct> pubkey, // In/Out
    ffi.Pointer<ffi.Uint8> tweak);
typedef PubkeyTweakAddDart = int Function(
    ffi.Pointer<Secp256k1Context> ctx,
    ffi.Pointer<Secp256k1PubkeyStruct> pubkey,
    ffi.Pointer<ffi.Uint8> tweak);


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
  required List<int> scalarTweakBytes,  // 32 bytes (IL from HMAC)
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
    throw ArgumentError("Parent public key must be 33 (compressed) or 65 (uncompressed) bytes.");
  }

  final arena = Arena();
  try {
    // 1. Prepare parent public key input
    final ffi.Pointer<ffi.Uint8> parentInputPtr = arena.allocate<ffi.Uint8>(parentPubKeyBytes.length);
    parentInputPtr.asTypedList(parentPubKeyBytes.length).setAll(0, parentPubKeyBytes);

    // Allocate space for the internal secp256k1_pubkey struct (64 bytes)
    final ffi.Pointer<Secp256k1PubkeyStruct> pubkeyStructPtr =
        arena.allocate<ffi.Uint8>(64).cast<Secp256k1PubkeyStruct>();

    // 2. Parse parent public key bytes into the struct
    int success = _pubkeyParse!(_context!, pubkeyStructPtr, parentInputPtr, parentPubKeyBytes.length);
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
    final ffi.Pointer<ffi.Uint8> serializedResultPtr = arena.allocate<ffi.Uint8>(outputSizeBytes);
    final ffi.Pointer<ffi.Size> actualOutputLenPtr = arena.allocate<ffi.Size>(1);
    actualOutputLenPtr.value = outputSizeBytes;

    success = _pubkeySerialize!(
      _context!,
      serializedResultPtr,
      actualOutputLenPtr,
      pubkeyStructPtr,
      _SECP256K1_EC_COMPRESSED_FLAG
    );

    if (success == 1) {
      return Uint8List.fromList(serializedResultPtr.asTypedList(actualOutputLenPtr.value));
    } else {
      print("FFI: secp256k1_ec_pubkey_serialize failed for child public key.");
      return null;
    }
  } finally {
    arena.releaseAll();
  }
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

  static Uint8List _pureDart_publicKeyScalarAdd(List<int> parentPubKeyBytes, List<int> scalarTweakBytes){
    var type = EllipticCurveTypes.secp256k1;
    final generator = EllipticCurveGetter.generatorFromType(type);

    var pubKey = Bip32PublicKey.fromBytes(parentPubKeyBytes, Bip32KeyData(), Bip32KeyNetVersions([],[]), type);

    final newPubKeyPoint = pubKey.point + (generator * BigintUtils.fromBytes(scalarTweakBytes));
    return _ensureUint8List(newPubKeyPoint.toBytes());
  }

  // Helper (keep static or move outside if used elsewhere)
  // Helper to convert List<int> to Uint8List if not already
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
}

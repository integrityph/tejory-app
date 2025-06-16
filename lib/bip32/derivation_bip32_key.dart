import 'dart:convert';
import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:tejory/libsecp256k1ffi/libsecp256k1ffi.dart';

class DerivationBIP32Key {
  List<int>? privateKey;
  List<int>? _publicKey;
  Bip32Depth? depth;
  Bip32KeyIndex? index;
  Bip32ChainCode? chainCode;
  Bip32FingerPrint? _fingerPrint;
  Bip32FingerPrint? parentFingerPrint;
  Bip32KeyNetVersions? keyNetVer;
  EllipticCurveTypes curveType = EllipticCurveTypes.secp256k1;

  DerivationBIP32Key({
    List<int>? publicKey,
    this.privateKey,
    this.chainCode,
    this.depth,
    this.index,
    Bip32FingerPrint? fingerPrint,
    Bip32KeyNetVersions? keyNetVer,
    this.parentFingerPrint,
  }) : _publicKey = publicKey,
       _fingerPrint = fingerPrint,
       this.keyNetVer = keyNetVer ?? defaultKeyNetVersion;

  DerivationBIP32Key.fromBip32Slip10Secp256k1(Bip32Slip10Secp256k1 key) {
    privateKey = key.privateKey.raw;
    _publicKey = key.publicKey.compressed;
    depth = key.depth;
    index = key.index;
    chainCode = key.chainCode;
    _fingerPrint = key.fingerPrint;
    keyNetVer = key.keyNetVersions;
  }

  DerivationBIP32Key.fromSeed({
    required List<int> seedBytes, // The 64-byte BIP39 seed
    required Bip32KeyNetVersions keyNetVersions,
    String hmacKeyString = "Bitcoin seed", // BIP32 standard for secp256k1
  }) {
    if (seedBytes.length < 16 || seedBytes.length > 64) {
      // BIP32 recommends 16-64 bytes
      throw ArgumentError(
        "Seed length must be between 16 and 64 bytes. got ${seedBytes.length}",
      );
    }

    final hmacSha512 = crypto.Hmac(crypto.Sha512());
    final secretKey = crypto.SecretKeyData(utf8.encode(hmacKeyString));
    final mac = hmacSha512.toSync().calculateMacSync(
      seedBytes,
      secretKeyData: secretKey,
      nonce: <int>[],
    );
    final I = mac.bytes; // 64-byte output

    final List<int> masterPrivateKeyBytes = I.sublist(0, 32);
    final List<int> masterChainCodeBytes = I.sublist(32);
    bool isZero = masterPrivateKeyBytes.every((byte) => byte == 0);
    // A full check against curve order N is more robust. libsecp256k1_ec_seckey_verify does this.
    // If you don't have an FFI for seckey_verify, this step is harder to do perfectly here.
    // Bip32PrivateKey.fromBytes in blockchain_utils does this check.
    if (isZero /* || masterPrivateKeyScalar >= N */ ) {
      throw ArgumentError(
        "Generated master private key is invalid (zero or >= N). Try a different seed or HMAC key.",
      );
    }

    privateKey = masterPrivateKeyBytes;
    chainCode = Bip32ChainCode(masterChainCodeBytes);
    depth = Bip32Depth(0);
    index = Bip32KeyIndex(0);
    parentFingerPrint = Bip32FingerPrint(Uint8List(4));
    keyNetVer = keyNetVersions;
  }

  DerivationBIP32Key.fromExtendedKey(
    String exKeyStr, [
    Bip32KeyNetVersions? keyNetVer,
  ]) {
    keyNetVer ??= defaultKeyNetVersion;
    final serKeyBytes = Base58Decoder.checkDecode(exKeyStr);
    bool isPublic =
        String.fromCharCodes(
          serKeyBytes.sublist(0, Bip32KeyNetVersions.length),
        ) ==
        String.fromCharCodes(keyNetVer.public);

    final depthIdx = Bip32KeyNetVersions.length;
    final fprintIdx = depthIdx + Bip32Depth.fixedLength();
    final keyIndexIdx = fprintIdx + Bip32FingerPrint.fixedLength();
    final chainCodeIdx = keyIndexIdx + Bip32KeyIndex.fixedLength();
    final keyIdx = chainCodeIdx + Bip32ChainCode.fixedLength();

    // Get parts
    final depth = serKeyBytes[depthIdx];
    final fprintBytes = serKeyBytes.sublist(fprintIdx, keyIndexIdx);
    final keyIndexBytes = serKeyBytes.sublist(keyIndexIdx, chainCodeIdx);
    final chainCodeBytes = serKeyBytes.sublist(chainCodeIdx, keyIdx);
    var keyBytes = serKeyBytes.sublist(keyIdx);

    if (!isPublic) {
      if (keyBytes[0] != 0) {
        throw Exception(
          'Invalid extended private key (wrong secret: ${keyBytes[0]})',
        );
      }
      keyBytes = keyBytes.sublist(1);
      this.privateKey = keyBytes;
    } else {
      this._publicKey = keyBytes;
    }
    this.depth = Bip32Depth(depth);
    this._fingerPrint = Bip32FingerPrint(fprintBytes);
    this.index = Bip32KeyIndex(IntUtils.fromBytes(keyIndexBytes));
    this.chainCode = Bip32ChainCode(chainCodeBytes);
  }

  static Bip32KeyNetVersions get defaultKeyNetVersion {
    return Bip32KeyNetVersions(
      [0x04, 0x35, 0x87, 0xCF],
      [0x04, 0x35, 0x83, 0x94],
    );
  }

  Bip32KeyData getBip32KeyData() {
    return Bip32KeyData(
      chainCode: chainCode,
      depth: depth,
      index: index,
      parentFingerPrint: parentFingerPrint,
    );
  }

  Bip32Slip10Secp256k1 toBip32Slip10Secp256k1() {
    if (privateKey != null) {
      return Bip32Slip10Secp256k1.fromPrivateKey(
        privateKey!,
        keyData: getBip32KeyData(),
        keyNetVer: keyNetVer,
      );
    } else {
      return Bip32Slip10Secp256k1.fromPublicKey(
        publicKey,
        keyData: getBip32KeyData(),
        keyNetVer: keyNetVer,
      );
    }
  }

  List<int> get publicKey {
    if (this._publicKey != null) {
      return this._publicKey!;
    }
    this._publicKey = LibSecp256k1FFI.derivePublicKey(
      privateKeyBytes: this.privateKey!,
      compressed: true,
    );
    return this._publicKey!;
  }

  void set publicKey(List<int>? val) {
    this._publicKey == val;
  }

  Bip32FingerPrint get fingerPrint {
    if (this._fingerPrint == null) {
      this._fingerPrint = Bip32FingerPrint(QuickCrypto.hash160(publicKey));
    }
    return this._fingerPrint!;
  }

  void set fingerPrint(Bip32FingerPrint? val) {
    this._fingerPrint == val;
  }

  String get extendedPrivateKey {
    final List<int> serKey = List<int>.from([
      ...keyNetVer!.private,
      ...depth!.toBytes(),
      ...parentFingerPrint!.toBytes(),
      ...index!.toBytes(),
      ...chainCode!.toBytes(),
      ...[0x00, ...privateKey!],
    ]);
    return Base58Encoder.checkEncode(serKey);
  }

  String get extendedPublicKey {
    final List<int> serKey = List<int>.from([
      ...keyNetVer!.public,
      ...depth!.toBytes(),
      ...parentFingerPrint!.toBytes(),
      ...index!.toBytes(),
      ...chainCode!.toBytes(),
      ...publicKey,
    ]);
    return Base58Encoder.checkEncode(serKey);
  }

  DerivationBIP32Key? derivePath(String path) {
    final pathInstance = Bip32PathParser.parse(path);
    DerivationBIP32Key? key = this;
    for (final pathElement in pathInstance.elems) {
      key = key?.childKey(pathElement);
    }
    return key;
  }

  DerivationBIP32Key? childKey(Bip32KeyIndex index) {
    DerivationBIP32Key key = this;
    final isPublic = key.privateKey == null;

    if (!isPublic) {
      final result = ckdPriv(key, index, key.curveType);
      return DerivationBIP32Key(
        chainCode: Bip32ChainCode(result.item2),
        depth: key.depth!.increase(),
        index: index,
        parentFingerPrint: key.parentFingerPrint,
        keyNetVer: key.keyNetVer,
        privateKey: result.item1,
      );
    }

    if (index.isHardened) {
      print(
        "Public child derivation cannot be used to create an hardened child key",
      );
      return null;
    }
    final result = ckdPub(key, index, key.curveType);
    if (result == null) {
      return null;
    }
    DerivationBIP32Key newKey = DerivationBIP32Key(
      chainCode: Bip32ChainCode(result.item2),
      depth: key.depth!.increase(),
      index: index,
      parentFingerPrint: key.fingerPrint,
      keyNetVer: key.keyNetVer,
      publicKey: result.item1,
    );
    return newKey;
  }

  List<int>? signMessage(
    List<int> message, {
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  }) {
    final sig = LibSecp256k1FFI.signMessage(
      Uint8List.fromList(message),
      Uint8List.fromList(privateKey!),
      messagePrefix: Uint8List.fromList(messagePrefix.codeUnits),
    );
    if (sig == null) {
      return null;
    }
    return _extractRnSFromDer(sig);
  }

  static BigInt _bytesToBigInt(Uint8List bytes) {
    if (bytes.length > 32) {
      throw ArgumentError("Bytes length exceeds 32 for BigInt conversion.");
    }
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result = (result << 8) | BigInt.from(bytes[i]);
    }
    return result;
  }

  Uint8List _bigIntTo32Bytes(BigInt value) {
    final bytes = Uint8List(32);
    if (value < BigInt.zero) {
        throw ArgumentError("Cannot convert negative BigInt to fixed-size unsigned bytes.");
    }
    for (int i = 0; i < 32; i++) {
      bytes[31 - i] = (value & BigInt.from(0xFF)).toInt();
      value = value >> 8;
    }
    if (value != BigInt.zero) {
        // This should not happen if the BigInt fits in 32 bytes (N and S values do)
        throw StateError("BigInt value too large for 32 bytes.");
    }
    return bytes;
  }

  Uint8List? _extractRnSFromDer(Uint8List derSignature) {
    final BigInt _N_BIG_INT = BigInt.parse('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141', radix: 16);
    // Half of the curve order (N/2) - used for canonical S value check
    final BigInt _N_OVER_2 = _N_BIG_INT ~/ BigInt.two;
    if (derSignature.isEmpty) {
      print("Error: DER signature is empty.");
      return null;
    }

    int offset = 0;

    // 1. Check for SEQUENCE tag (0x30)
    if (derSignature[offset] != 0x30) {
      print("Error: DER signature does not start with SEQUENCE tag (0x30).");
      return null;
    }
    offset++;

    // 2. Read total length
    int totalLen = derSignature[offset];
    offset++;

    // Handle multi-byte length encoding
    if (totalLen & 0x80 != 0) {
      int numBytes = totalLen & 0x7F;
      if (numBytes == 0 || offset + numBytes > derSignature.length) {
        print("Error: Invalid multi-byte length encoding.");
        return null;
      }
      totalLen = 0;
      for (int i = 0; i < numBytes; i++) {
        totalLen = (totalLen << 8) | derSignature[offset + i];
      }
      offset += numBytes;
    }

    if (totalLen != derSignature.length - offset) {
      print("Error: Reported total length ($totalLen) does not match actual remaining bytes (${derSignature.length - offset}).");
      return null;
    }

    Uint8List? rBytes;
    Uint8List? sBytesRaw; // Store raw S bytes before canonicalization

    for (int i = 0; i < 2; i++) { // Loop for R and then S
      // Check for INTEGER tag (0x02)
      if (offset >= derSignature.length || derSignature[offset] != 0x02) {
        print("Error: Expected INTEGER tag (0x02) for R or S at offset $offset.");
        return null;
      }
      offset++;

      // Read integer length
      if (offset >= derSignature.length) {
        print("Error: Missing length byte for R or S integer at offset $offset.");
        return null;
      }
      int intLen = derSignature[offset];
      offset++;

      if (intLen & 0x80 != 0) {
          print("Warning: Multi-byte length for R or S integer encountered (uncommon).");
          return null; // Or implement full multi-byte int length parsing
      }

      // Extract bytes for R or S
      if (offset + intLen > derSignature.length) {
        print("Error: Integer data extends beyond signature bounds. Offset: $offset, Length: $intLen, Der Length: ${derSignature.length}.");
        return null;
      }
      Uint8List currentBytes = derSignature.sublist(offset, offset + intLen);
      offset += intLen;

      // Handle leading zero byte for positive numbers
      if (currentBytes.length > 1 && currentBytes[0] == 0x00 && currentBytes[1] >= 0x80) {
        currentBytes = currentBytes.sublist(1);
      }

      // Ensure R and S are exactly 32 bytes (pad with leading zeros if shorter, error if longer)
      if (currentBytes.length < 32) {
        final padded = Uint8List(32);
        padded.setAll(32 - currentBytes.length, currentBytes); // Pad leading zeros
        currentBytes = padded;
      } else if (currentBytes.length > 32) {
          print("Error: R or S component is larger than 32 bytes after stripping leading zero.");
          return null;
      }

      if (i == 0) { // First iteration for R
        rBytes = currentBytes;
      } else {    // Second iteration for S
        sBytesRaw = currentBytes;
      }
    }

    if (rBytes == null || sBytesRaw == null) {
      print("Error: Failed to extract both R and S components.");
      return null;
    }

    BigInt sBigInt = _bytesToBigInt(sBytesRaw);

    if (sBigInt > _N_OVER_2) {
      sBigInt = _N_BIG_INT - sBigInt;
      sBytesRaw = _bigIntTo32Bytes(sBigInt); // Update sBytesRaw with canonical value
      print("Debug: Signature S value was non-canonical and has been normalized to lower half.");
    }


    // Concatenate R and the (potentially canonicalized) S into a single 64-byte Uint8List
    final Uint8List concatenatedRnS = Uint8List(64);
    concatenatedRnS.setAll(0, rBytes);
    concatenatedRnS.setAll(32, sBytesRaw); // Use the (potentially modified) sBytesRaw

    return concatenatedRnS;
  }

  Tuple<List<int>, List<int>> ckdPriv(
    DerivationBIP32Key key,
    Bip32KeyIndex index,
    EllipticCurveTypes type,
  ) {
    List<int> dataBytes;
    if (index.isHardened) {
      dataBytes = List<int>.from([
        ...Bip32Slip10DerivatorConst.priveKeyPrefix,
        ...key.privateKey!,
        ...index.toBytes(),
      ]);
    } else {
      dataBytes = List<int>.from([...key.publicKey, ...index.toBytes()]);
    }
    final hmacHalves = crypto.Hmac.sha512().toSync().calculateMacSync(
      dataBytes,
      secretKeyData: crypto.SecretKeyData(key.chainCode!.toBytes()),
      nonce: [],
    );

    final ilBytes = hmacHalves.bytes.sublist(0, 32);
    final irBytes = hmacHalves.bytes.sublist(32, 64);
    final scalar = LibSecp256k1FFI.addScalar(
      privKeyBytes: key.privateKey!,
      newScalarBytes: ilBytes,
    );

    final newPrivKeyBytes = BigintUtils.toBytes(
      scalar!,
      order: Endian.big,
      length: key.privateKey!.length,
    );

    return Tuple(newPrivKeyBytes, irBytes);
  }

  Tuple<List<int>, List<int>>? ckdPub(
    DerivationBIP32Key pubKey,
    Bip32KeyIndex index,
    EllipticCurveTypes type,
  ) {
    final dataBytes = List<int>.from([...publicKey, ...index.toBytes()]);
    final hmacHalves = crypto.Hmac.sha512().toSync().calculateMacSync(
      dataBytes,
      secretKeyData: crypto.SecretKeyData(pubKey.chainCode!.toBytes()),
      nonce: [],
    );

    final ilBytes = hmacHalves.bytes.sublist(0, 32);
    final irBytes = hmacHalves.bytes.sublist(32, 64);
    // final ilInt = BigintUtils.fromBytes(ilBytes);
    // final generator = EllipticCurveGetter.generatorFromType(type);

    // final newPubKeyPoint = pubKey.point + (generator * ilInt);
    final newPubKeyPoint = LibSecp256k1FFI.publicKeyScalarAdd(
      parentPubKeyBytes: pubKey.publicKey,
      scalarTweakBytes: ilBytes,
    );
    if (newPubKeyPoint == null) {
      print("unable to perform public key scalar addition");
      return null;
    }
    return Tuple(newPubKeyPoint, irBytes);
  }
}

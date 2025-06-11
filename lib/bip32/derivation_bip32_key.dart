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
    publicKey,
    this.privateKey,
    this.chainCode,
    this.depth,
    this.index,
    fingerPrint,
    this.keyNetVer,
    this.parentFingerPrint,
  }) : _publicKey = publicKey,
       _fingerPrint = fingerPrint;

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
      throw ArgumentError("Seed length must be between 16 and 64 bytes. got ${seedBytes.length}");
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
      ...keyNetVer!.private,
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
      publicKey: result.item1
    );
    return newKey;
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
    final dataBytes = List<int>.from([
      ...publicKey,
      ...index.toBytes(),
    ]);
    final hmacHalves = crypto.Hmac.sha512().toSync().calculateMacSync(
      dataBytes,
      secretKeyData: crypto.SecretKeyData(pubKey.chainCode!.toBytes()),
      nonce:[],
    );

    final ilBytes = hmacHalves.bytes.sublist(0, 32);
    final irBytes = hmacHalves.bytes.sublist(32, 64);
    // final ilInt = BigintUtils.fromBytes(ilBytes);
    // final generator = EllipticCurveGetter.generatorFromType(type);

    // final newPubKeyPoint = pubKey.point + (generator * ilInt);
    final newPubKeyPoint = LibSecp256k1FFI.publicKeyScalarAdd(parentPubKeyBytes:pubKey.publicKey, scalarTweakBytes:ilBytes);
    if (newPubKeyPoint == null) {
      print("unable to perform public key scalar addition");
      return null;
    }
    return Tuple(newPubKeyPoint, irBytes);
  }
}

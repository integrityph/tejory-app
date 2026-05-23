import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:biometric_signature/biometric_signature.dart';

// pointycastle should be replaced with BoringSSL once ECDH secp256r1 is implemented there
import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_bit_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/export.dart' hide Padding, State;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:boringssl_ffi/boringssl_ffi.dart' as bssl;

class SEHelper {
  static final BiometricSignature _biometricSignature = BiometricSignature();
  static String? publicKey;

  static final publicKeyLength = 65;
  static final publicKeyPrefix = 0x04;
  static final nonceLength = 16;
  static final privateKeyLength = 32;
  static final _unlockedEncryptionKey = Uint8List(32);
  static bool _isKeyUnlocked = false;
  static FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(),
    aOptions: AndroidOptions(),
  ); // defaults don't need biometric
  static const String lockedEncryptionKeyName = "LockedEncryptionKey";
  static final Completer<void> ready = Completer();

  static Uint8List? encrypt(Uint8List msg) {
    final random = Random.secure();
    final nonce = Uint8List.fromList(List.generate(12, (_) => random.nextInt(256)));
    final cipherText = bssl.aead.sealAES_GCM(msg, Uint8List(0), _unlockedEncryptionKey, nonce);
    if (cipherText == null) {
      return null;
    }
    return Uint8List.fromList((nonce + cipherText));
  }

  static Uint8List? decrypt(Uint8List ct) {
    if (ct.length < 12) {
      print("cipher text length is less than 12 bytes");
      return null;
    }
    final nonce = ct.sublist(0, 12);
    final msg = bssl.aead.openAES_GCM(ct.sublist(12), Uint8List(0), _unlockedEncryptionKey, nonce);
    if (msg == null) {
      return null;
    }
    return msg;
  }

  static bool isEncryptionKeyUnlocked() {
    return _isKeyUnlocked;
  }

  static Future<Uint8List?> getLockedEncryptionKey() async {
    final keyExists = await _secureStorage.containsKey(key: lockedEncryptionKeyName);
    if (!keyExists) {
      return null;
    }

    final lockedKeyB64 =  await _secureStorage.read(key: lockedEncryptionKeyName);
    if (lockedKeyB64 == null) {
      return null;
    }

    try {
      final lockedKey = base64Decode(lockedKeyB64);

      if (lockedKey.isEmpty) {
        return null;
      }

      return lockedKey;
    } catch (e) {
      print("Unable to decode lockedKey as base64");
      return null;
    }
  }

  static Future<bool> unlock() async {
    Uint8List? lockedKey = await getLockedEncryptionKey();

    print("unlock the value of lockedKey is null? ${lockedKey == null}");

    if (lockedKey == null) {
      // generate a new key
      lockedKey = await _createLockedEncryptionKey();

      if (lockedKey == null) {
        print("Unable to create lockedKey");
        _isKeyUnlocked = false;
        return _isKeyUnlocked;
      }
      _isKeyUnlocked = true;
      // if (!ready.isCompleted) ready.complete();
      ready.complete();
      return _isKeyUnlocked;
    } else {
      // unlock the locked key
      final Uint8List? tempKey = await _decryptSE(lockedKey);
      if (tempKey == null || tempKey.length != privateKeyLength) {
        tempKey?.fillRange(0, tempKey.length, 0);
        _isKeyUnlocked = false;
        return _isKeyUnlocked;
      }
      
      _unlockedEncryptionKey.setAll(0, tempKey);
      tempKey.fillRange(0, tempKey.length, 0);
      _isKeyUnlocked = true;
      // if (!ready.isCompleted) ready.complete();
      ready.complete();
      return _isKeyUnlocked;
    }
  }

  static void lock() {
    _isKeyUnlocked = false;
    _unlockedEncryptionKey.fillRange(0, _unlockedEncryptionKey.length, 0);
  }

  // This method will generate an unlocked key and 
  static Future<Uint8List?> _createLockedEncryptionKey() async {
    // first, generate an unlocked key
    final random = Random.secure();
    for (int i=0; i<32; i++){
      _unlockedEncryptionKey.fillRange(i, i+1, random.nextInt(256));
    }
    
    final lockedKey = await _encryptSE(_unlockedEncryptionKey);
    if (lockedKey == null) {
      _unlockedEncryptionKey.fillRange(0, _unlockedEncryptionKey.length, 0);
      return null;
    }

    final lockedKeyB64 = base64Encode(lockedKey);
    _secureStorage.write(key: lockedEncryptionKeyName, value: lockedKeyB64);

    return lockedKey;
  }

  static Future<Uint8List?> _encryptSE(Uint8List rawBytes) async {
    // Parse recipient's public key (handling both PEM and raw Base64 if needed)
    final publicKeyStr = await _getPublicKey();
    if (publicKeyStr == null) {
      return null;
    }
    // Note: _parseEcPublicKeyFromPem handles stripping headers
    final ecPublicKey = _parseEcPublicKeyFromPem(publicKeyStr);

    // Generate ephemeral keypair
    final ephemeralKeyPair = _generateEphemeralKeyPair(ecPublicKey.parameters!);
    final ephemeralPublic = ephemeralKeyPair.publicKey as ECPublicKey;
    final ephemeralPrivate = ephemeralKeyPair.privateKey as ECPrivateKey;

    // ECDH key agreement
    final agreement = ECDHBasicAgreement()..init(ephemeralPrivate);
    final sharedSecret = agreement.calculateAgreement(ecPublicKey);

    // Output: [EphemeralPubKey (Uncompressed 65)] || [Ciphertext + Tag]
    final isApple = Platform.isIOS || Platform.isMacOS;
    final ephemeralPubBytes = ephemeralPublic.Q!.getEncoded(
      false,
    ); // Uncompressed required

    // ECIES Parameters
    // Hypothesis: Apple Standard Mode uses Static Zero IV and binds EphemKey in SharedInfo.
    final sharedInfo = isApple ? ephemeralPubBytes : Uint8List(0);

    Uint8List gcmIv;
    Uint8List aesKey;
    final Uint8List aad;

    if (isApple) {
      // iOS Standard Mode Hypothesis
      // 1. IV is Static Zeros (16 bytes).
      // 2. KDF derives ONLY Key (16 bytes).
      final keySize = 16;
      aesKey = _kdfX963(sharedSecret, keySize, sharedInfo);
      gcmIv = Uint8List(16); // Zero IV
    } else {
      // Android Standard Mode (Derived IV)
      final keySize = 16;
      final ivSize = 12;
      final derived = _kdfX963(sharedSecret, keySize + ivSize, sharedInfo);
      aesKey = derived.sublist(0, keySize);
      gcmIv = derived.sublist(keySize, keySize + ivSize);
    }

    aad = Uint8List(0);

    // AES-GCM encryption
    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(true, AEADParameters(KeyParameter(aesKey), 128, gcmIv, aad));
    final ciphertext = cipher.process(
      utf8.encode(base64Encode(rawBytes)),
    );

    // Construct Payload: [EphemKey] [Ciphertext]
    // Note: Android uses same payload structure
    final payloadParts = [ephemeralPubBytes, ciphertext];
    
    final encryptedBytes = Uint8List.fromList(payloadParts.expand((x) => x).toList());
    return encryptedBytes;
  }

  static Future<Uint8List?> _decryptSE(Uint8List payload) async {
    final encryptedBase64 = base64Encode(payload);

    final result = await _biometricSignature.decrypt(
      payload: encryptedBase64,
      payloadFormat: PayloadFormat.base64,
      promptMessage: 'Unlock Wallet Keys',
      config: DecryptConfig(
        allowDeviceCredentials: false,
      ),
    );

    if (result.code != BiometricError.success) {
      print("Unable to decrypt keyset. ${result.code}: ${result.error}");
      return null;
    }

    // put thigs back in keyset
    final decryptedBytes = base64Decode(result.decryptedData!);
    return decryptedBytes;
  }

  static bool isKeysetEncrypted(List<({Uint8List chainCode, String path, Uint8List privateKey})>? keyset) {
    if (keyset == null) {
      return false;
    }

    bool isEncrypted = false;
        // This is the key that has the public encryption key and the nonce
    if (keyset[0].privateKey.length > publicKeyLength + nonceLength && keyset[0].privateKey[0] == publicKeyPrefix) {
      isEncrypted = true;
    }

    return isEncrypted;
  }

  static Future<String?> _getPublicKey([KeyFormat keyFormat=KeyFormat.pem]) async {
    
    final info = await _biometricSignature.getKeyInfo(
      checkValidity: true,
      keyFormat: keyFormat,
    );

    if ((info.exists ?? false) && (info.decryptingPublicKey != null)) {
      return info.decryptingPublicKey!;
    }

    while (true) {
      try {  
        // Create new key
        return await _createNewKey();
      } catch (e) {
        print("Unable to get Public Key. ${e.toString()}");
        continue;
      }
    }
  }

  static Future<String> _createNewKey([KeyFormat keyFormat=KeyFormat.pem]) async {
    try {
      final result = await _biometricSignature.createKeys(
        keyFormat: keyFormat,
        promptMessage: 'Authenticate to create keys',
        config: CreateKeysConfig(
          useDeviceCredentials: false,
          signatureType: SignatureType.ecdsa,
          setInvalidatedByBiometricEnrollment: true,
          enforceBiometric: true,
          enableDecryption: true,
        ),
      );

      if (result.code == BiometricError.fallbackSelected) {
        throw Exception('Fallback selected during key creation');
      }

      if (result.code == BiometricError.success) {
        return result.decryptingPublicKey!;
      } else {
        throw Exception('Error: ${result.code} - ${result.error}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static ECPublicKey _parseEcPublicKeyFromPem(String pem) {
    // Strip headers if present
    final rows = pem
        .split('\n')
        .where((l) => !l.startsWith('-----') && l.trim().isNotEmpty)
        .join('');
    final bytes = base64Decode(rows);
    final params = ECDomainParameters('secp256r1');
    Uint8List pubBytes;

    try {
      final parser = ASN1Parser(bytes);
      final topLevel = parser.nextObject();

      if (topLevel is ASN1Sequence) {
        // SPKI format (Android)
        final bitString = topLevel.elements![1] as ASN1BitString;
        pubBytes = Uint8List.fromList(bitString.stringValues!);
      } else {
        // iOS returns raw bytes (often parses as OctetString due to 0x04 tag)
        pubBytes = bytes;
      }
    } catch (_) {
      // Fallback to raw bytes just in case
      pubBytes = bytes;
    }

    final q = params.curve.decodePoint(pubBytes)!;
    return ECPublicKey(q, params);
  }

  static AsymmetricKeyPair<PublicKey, PrivateKey> _generateEphemeralKeyPair(
    ECDomainParameters params,
  ) {
    final generator = ECKeyGenerator();
    generator.init(
      ParametersWithRandom(ECKeyGeneratorParameters(params), _secureRandom()),
    );
    return generator.generateKeyPair();
  }

  static SecureRandom _secureRandom() {
    final rng = FortunaRandom();
    final seed = Uint8List(32);
    final random = Random.secure();
    for (var i = 0; i < 32; i++) {
      seed[i] = random.nextInt(256);
    }
    rng.seed(KeyParameter(seed));
    return rng;
  }

  static Uint8List _kdfX963(BigInt sharedSecret, int length, Uint8List sharedInfo) {
    final digest = SHA256Digest();
    final secretBytes = _bigIntToBytes(sharedSecret, 32);
    final result = Uint8List(length);
    var offset = 0;
    var counter = 1;

    while (offset < length) {
      digest.reset();
      digest.update(secretBytes, 0, secretBytes.length);
      digest.updateByte((counter >> 24) & 0xff);
      digest.updateByte((counter >> 16) & 0xff);
      digest.updateByte((counter >> 8) & 0xff);
      digest.updateByte(counter & 0xff);
      digest.update(sharedInfo, 0, sharedInfo.length);

      final hash = Uint8List(digest.digestSize);
      digest.doFinal(hash, 0);

      final toCopy = (length - offset).clamp(0, hash.length);
      result.setRange(offset, offset + toCopy, hash);
      offset += toCopy;
      counter++;
    }
    return result;
  }

  static Uint8List _bigIntToBytes(BigInt number, int length) {
    var hex = number.toRadixString(16);
    if (hex.length % 2 != 0) hex = '0$hex';

    final bytes = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }

    if (bytes.length >= length) return bytes.sublist(bytes.length - length);

    final padded = Uint8List(length);
    padded.setRange(length - bytes.length, length, bytes);
    return padded;
  }

  static BigInt _bytesToBigIntBE(List<int> val) {
    BigInt result = BigInt.zero;

    for (final byte in val) {
      result = (result << 8) | BigInt.from(byte & 0xff);
    }

    return result;
  }
}
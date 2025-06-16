import 'dart:typed_data';
import 'package:blockchain_utils/hex/hex.dart';
import 'package:elliptic/src/publickey.dart';
import 'package:ecdsa/src/signature.dart';
import 'package:elliptic/src/base.dart';
import 'package:elliptic/src/elliptic.dart';
import 'package:intl/intl.dart';
import 'package:tejory/singleton.dart';

class OtherHelpers {
  static String humanizeMoney(double val, {bool isFiat=false, bool addFiatSymbol=true}) {
    if (isFiat) {
      val *= Singleton.currentCurrency.usdMultiplier;
    }
    String strVal;
    if (val == 0.0) {
      strVal = val.toStringAsFixed(2);
    } else if (val >= 1.00) {
      var formatter = NumberFormat.decimalPatternDigits(
        locale: 'en_us',
        decimalDigits: 2,
      );
      strVal = formatter.format(val);
    } else if (val >= 0.10) {
      strVal = val.toStringAsFixed(3);
    } else if (val >= 0.01) {
      strVal = val.toStringAsFixed(4);
    } else if (val >= 0.001) {
      strVal = val.toStringAsFixed(5);
    } else if (val >= 0.0001) {
      strVal = val.toStringAsFixed(6);
    } else if (val >= 0.00001) {
      strVal = val.toStringAsFixed(7);
    } else {
      strVal = val.toStringAsFixed(8);
    }
    if (isFiat && addFiatSymbol) {
      if (Singleton.currentCurrency.symbolBeforeNumber) {
        return Singleton.currentCurrency.symbol + strVal;
      } else {
        return "$strVal ${Singleton.currentCurrency.symbol}";
      }
    }
    return strVal;
  }

  static AffinePoint pointMultiply(Uint8List pubKey, BigInt multiplier) {
    EllipticCurve _s256 = EllipticCurve(
      'secp256k1',
      256,
      BigInt.parse(
          'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
          radix: 16), // p
      BigInt.zero, // a
      BigInt.from(7), // b
      BigInt.zero, // S
      AffinePoint.fromXY(
          BigInt.parse(
              '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
              radix: 16),
          BigInt.parse(
              '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',
              radix: 16)), // G
      BigInt.parse(
          'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
          radix: 16), // n
      01, // h
    );
    var curve = _s256;
    PublicKey pub = PublicKey.fromHex(curve, hex.encode(pubKey));
    var pubPoint = AffinePoint.fromXY(pub.X, pub.Y);

    var mArray = hex.decode(multiplier.toRadixString(16).padLeft((multiplier.bitLength/8).ceil()*2, "0"));

    return curve.scalarMul(pubPoint, mArray);
  }

	static AffinePoint pointMultiplyArray(Uint8List pubKey, Uint8List multiplier) {
    EllipticCurve _s256 = EllipticCurve(
      'secp256k1',
      256,
      BigInt.parse(
          'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
          radix: 16), // p
      BigInt.zero, // a
      BigInt.from(7), // b
      BigInt.zero, // S
      AffinePoint.fromXY(
          BigInt.parse(
              '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
              radix: 16),
          BigInt.parse(
              '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',
              radix: 16)), // G
      BigInt.parse(
          'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
          radix: 16), // n
      01, // h
    );
    var curve = _s256;
    PublicKey pub = PublicKey.fromHex(curve, hex.encode(pubKey));
    var pubPoint = AffinePoint.fromXY(pub.X, pub.Y);

    return curve.scalarMul(pubPoint, multiplier);
  }

	static Uint8List pointAdd(Uint8List A, Uint8List B) {
    EllipticCurve _s256 = EllipticCurve(
      'secp256k1',
      256,
      BigInt.parse(
          'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
          radix: 16), // p
      BigInt.zero, // a
      BigInt.from(7), // b
      BigInt.zero, // S
      AffinePoint.fromXY(
          BigInt.parse(
              '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
              radix: 16),
          BigInt.parse(
              '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',
              radix: 16)), // G
      BigInt.parse(
          'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
          radix: 16), // n
      01, // h
    );
    var curve = _s256;
    PublicKey a = PublicKey.fromHex(curve, hex.encode(A));
		PublicKey b = PublicKey.fromHex(curve, hex.encode(B));
    var p1 = AffinePoint.fromXY(a.X, a.Y);
		var p2 = AffinePoint.fromXY(b.X, b.Y);

    return Uint8List.fromList(hex.decode(curve.add(p1, p2).X.toRadixString(16).padLeft(64)));
  }

  static int getYParity(Uint8List pubKey, List<int> hash, Uint8List rawSig) {
    EllipticCurve _s256 = EllipticCurve(
      'secp256k1',
      256,
      BigInt.parse(
          'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
          radix: 16), // p
      BigInt.zero, // a
      BigInt.from(7), // b
      BigInt.zero, // S
      AffinePoint.fromXY(
          BigInt.parse(
              '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
              radix: 16),
          BigInt.parse(
              '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',
              radix: 16)), // G
      BigInt.parse(
          'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
          radix: 16), // n
      01, // h
    );
    var curve = _s256;
    PublicKey pub = PublicKey.fromHex(curve, hex.encode(pubKey));
    Signature sig = Signature.fromDER(rawSig);
    // See [NSA] 3.4.2
    var byteLen = (curve.bitSize + 7) ~/ 8;

    if (sig.R.sign <= 0 || sig.S.sign <= 0) {
      return 0;
    }

    if (sig.R >= curve.n || sig.S >= curve.n) {
      return 0;
    }

    var e = bitsToInt(hash, curve.n.bitLength);
    var w = sig.S.modInverse(curve.n);

    var u1 = e * w;
    u1 = u1 % curve.n;
    var u2 = sig.R * w;
    u2 = u2 % curve.n;

    // Check if implements S1*g + S2*p
    var hexU1 = u1.toRadixString(16).padLeft(byteLen * 2, '0');
    var hexU2 = u2.toRadixString(16).padLeft(byteLen * 2, '0');
    var p1 = curve.scalarBaseMul(List<int>.generate(hexU1.length ~/ 2,
        (i) => int.parse(hexU1.substring(i * 2, i * 2 + 2), radix: 16)));
    var p2 = curve.scalarMul(
        pub,
        List<int>.generate(hexU2.length ~/ 2,
            (i) => int.parse(hexU2.substring(i * 2, i * 2 + 2), radix: 16)));
    var p = curve.add(p1, p2);

    return p.Y.isOdd ? 1 : 0;
  }

  static BigInt bitsToInt(List<int> hash, int qBitLen) {
    var orderBytes = (qBitLen + 7) ~/ 8;
    if (hash.length > qBitLen) {
      hash = hash.sublist(0, orderBytes);
    }

    var ret = BigInt.parse(
        List<String>.generate(
                hash.length, (i) => hash[i].toRadixString(16).padLeft(2, '0'))
            .join(),
        radix: 16);
    var excess = hash.length * 8 - qBitLen;
    if (excess > 0) {
      ret >> excess;
    }
    return ret;
  }
}

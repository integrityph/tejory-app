import 'dart:convert';

class TooShortHrp implements Exception {
  @override
  String toString() => 'The human readable part should have non zero length.';
}

class TooLong implements Exception {
  TooLong(this.length);

  final int length;

  @override
  String toString() => 'The bech32 string is too long: $length (>90)';
}

class OutOfRangeHrpCharacters implements Exception {
  OutOfRangeHrpCharacters(this.hpr);

  final String hpr;

  @override
  String toString() =>
      'The human readable part contains invalid characters: $hpr';
}

class MixedCase implements Exception {
  MixedCase(this.hpr);

  final String hpr;

  @override
  String toString() =>
      'The human readable part is mixed case, should either be all lower or all upper case: $hpr';
}

class OutOfBoundChars implements Exception {
  OutOfBoundChars(this.char);

  final String char;

  @override
  String toString() => 'A character is undefined in bech32: $char';
}

class InvalidSeparator implements Exception {
  InvalidSeparator(this.pos);

  final int pos;

  @override
  String toString() => "separator '1' at invalid position: $pos";
}

class InvalidAddress implements Exception {
  @override
  String toString() => '';
}

class InvalidChecksum implements Exception {
  @override
  String toString() => 'Checksum verification failed';
}

class TooShortChecksum implements Exception {
  @override
  String toString() => 'Checksum is shorter than 6 characters';
}

class InvalidHrp implements Exception {
  @override
  String toString() => "Human readable part should be 'bc' or 'tb'.";
}

class InvalidProgramLength implements Exception {
  InvalidProgramLength(this.reason);

  final String reason;

  @override
  String toString() => 'Program length is invalid: $reason';
}

class InvalidWitnessVersion implements Exception {
  InvalidWitnessVersion(this.version);

  final int version;

  @override
  String toString() => 'Witness version $version > 16';
}

class InvalidPadding implements Exception {
  InvalidPadding(this.reason);

  final String reason;

  @override
  String toString() => 'Invalid padding: $reason';
}
/// An instance of the default implementation of the Bech32Codec.
const Bech32mCodec bech32 = Bech32mCodec();

class Bech32mCodec extends Codec<Bech32m, String> {
  const Bech32mCodec();

  @override
  Bech32mDecoder get decoder => Bech32mDecoder();
  @override
  Bech32mEncoder get encoder => Bech32mEncoder();

  @override
  String encode(Bech32m data, [maxLength = Bech32mValidations.maxInputLength]) {
    return Bech32mEncoder().convert(data, maxLength);
  }

  @override
  Bech32m decode(String data, [maxLength = Bech32mValidations.maxInputLength]) {
    return Bech32mDecoder().convert(data, maxLength);
  }
}

// This class converts a Bech32 class instance to a String.
class Bech32mEncoder extends Converter<Bech32m, String>
    with Bech32mValidations {
  @override
  String convert(Bech32m input,
      [int maxLength = Bech32mValidations.maxInputLength]) {
    var hrp = input.hrp;
    var data = input.data;

    if (hrp.length +
            data.length +
            separator.length +
            Bech32mValidations.checksumLength >
        maxLength) {
      throw TooLong(
          hrp.length + data.length + 1 + Bech32mValidations.checksumLength);
    }

    if (hrp.isEmpty) {
      throw TooShortHrp();
    }

    if (hasOutOfRangeHrpCharacters(hrp)) {
      throw OutOfRangeHrpCharacters(hrp);
    }

    if (isMixedCase(hrp)) {
      throw MixedCase(hrp);
    }

    hrp = hrp.toLowerCase();

    var checksummed = data + _createChecksum(hrp, data);

    if (hasOutOfBoundsChars(checksummed)) {
      // TODO this could be more informative
      throw OutOfBoundChars('<unknown>');
    }

    return hrp + separator + checksummed.map((i) => charset[i]).join();
  }
}

// This class converts a String to a Bech32 class instance.
class Bech32mDecoder extends Converter<String, Bech32m>
    with Bech32mValidations {
  @override
  Bech32m convert(String input,
      [int maxLength = Bech32mValidations.maxInputLength]) {
    if (input.length > maxLength) {
      throw TooLong(input.length);
    }

    if (isMixedCase(input)) {
      throw MixedCase(input);
    }

    if (hasInvalidSeparator(input)) {
      throw InvalidSeparator(input.lastIndexOf(separator));
    }

    var separatorPosition = input.lastIndexOf(separator);

    if (isChecksumTooShort(separatorPosition, input)) {
      throw TooShortChecksum();
    }

    if (isHrpTooShort(separatorPosition)) {
      throw TooShortHrp();
    }

    input = input.toLowerCase();

    var hrp = input.substring(0, separatorPosition);
    var data = input.substring(separatorPosition + 1,
        input.length - Bech32mValidations.checksumLength);
    var checksum =
        input.substring(input.length - Bech32mValidations.checksumLength);

    if (hasOutOfRangeHrpCharacters(hrp)) {
      throw OutOfRangeHrpCharacters(hrp);
    }

    var dataBytes = data.split('').map((c) {
      return charset.indexOf(c);
    }).toList();

    if (hasOutOfBoundsChars(dataBytes)) {
      throw OutOfBoundChars(data[dataBytes.indexOf(-1)]);
    }

    var checksumBytes = checksum.split('').map((c) {
      return charset.indexOf(c);
    }).toList();

    if (hasOutOfBoundsChars(checksumBytes)) {
      throw OutOfBoundChars(checksum[checksumBytes.indexOf(-1)]);
    }

    if (isInvalidChecksum(hrp, dataBytes, checksumBytes)) {
      throw InvalidChecksum();
    }

    return Bech32m(hrp, dataBytes);
  }
}

/// Generic validations for Bech32 standard.
mixin Bech32mValidations {
  static const int maxInputLength = 90;
  static const checksumLength = 6;

  // From the entire input subtract the hrp length, the separator and the required checksum length
  bool isChecksumTooShort(int separatorPosition, String input) {
    return (input.length - separatorPosition - 1 - checksumLength) < 0;
  }

  bool hasOutOfBoundsChars(List<int> data) {
    return data.any((c) => c == -1);
  }

  bool isHrpTooShort(int separatorPosition) {
    return separatorPosition == 0;
  }

  bool isInvalidChecksum(String hrp, List<int> data, List<int> checksum) {
    return !_verifyChecksum(hrp, data + checksum);
  }

  bool isMixedCase(String input) {
    return input.toLowerCase() != input && input.toUpperCase() != input;
  }

  bool hasInvalidSeparator(String bech32) {
    return bech32.lastIndexOf(separator) == -1;
  }

  bool hasOutOfRangeHrpCharacters(String hrp) {
    return hrp.codeUnits.any((c) => c < 33 || c > 126);
  }
}

/// Bech32 is a dead simple wrapper around a Human Readable Part (HRP) and a
/// bunch of bytes.
class Bech32m {
  Bech32m(this.hrp, this.data);

  final String hrp;
  final List<int> data;
}

const String separator = '1';

const List<String> charset = [
  'q',
  'p',
  'z',
  'r',
  'y',
  '9',
  'x',
  '8',
  'g',
  'f',
  '2',
  't',
  'v',
  'd',
  'w',
  '0',
  's',
  '3',
  'j',
  'n',
  '5',
  '4',
  'k',
  'h',
  'c',
  'e',
  '6',
  'm',
  'u',
  'a',
  '7',
  'l',
];

const List<int> generator = [
  0x3b6a57b2,
  0x26508e6d,
  0x1ea119fa,
  0x3d4233dd,
  0x2a1462b3,
];

const int mConstant = 0x2bc830a3;

int _polymod(List<int> values) {
  var chk = 1;
  values.forEach((v) {
    var top = chk >> 25;
    chk = (chk & 0x1ffffff) << 5 ^ v;
    for (var i = 0; i < generator.length; i++) {
      if ((top >> i) & 1 == 1) {
        chk ^= generator[i];
      }
    }
  });

  return chk;
}

List<int> _hrpExpand(String hrp) {
  var result = hrp.codeUnits.map((c) => c >> 5).toList();
  result = result + [0];

  result = result + hrp.codeUnits.map((c) => c & 31).toList();

  return result;
}

bool _verifyChecksum(String hrp, List<int> dataIncludingChecksum) {
  return _polymod(_hrpExpand(hrp) + dataIncludingChecksum) == mConstant;
}

List<int> _createChecksum(String hrp, List<int> data) {
  var values = _hrpExpand(hrp) + data;
  var polymod = _polymod(values + [0, 0, 0, 0, 0, 0]) ^ mConstant;

  var result = <int>[0, 0, 0, 0, 0, 0];

  for (var i = 0; i < result.length; i++) {
    result[i] = (polymod >> (5 * (5 - i))) & 31;
  }
  return result;
}
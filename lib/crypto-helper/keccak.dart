import 'dart:math';
import 'dart:typed_data';

final keccakRoundConstants = [
  0x0000000000000001,
  0x0000000000008082,
  0x800000000000808a,
  0x8000000080008000,
  0x000000000000808b,
  0x0000000080000001,
  0x8000000080008081,
  0x8000000000008009,
  0x000000000000008a,
  0x0000000000000088,
  0x0000000080008009,
  0x000000008000000a,
  0x000000008000808b,
  0x800000000000008b,
  0x8000000000008089,
  0x8000000000008003,
  0x8000000000008002,
  0x8000000000000080,
  0x000000000000800a,
  0x800000008000000a,
  0x8000000080008081,
  0x8000000000008080,
  0x0000000080000001,
  0x8000000080008008
];

final keccakRotc = [
  1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 2, 14, //
  27, 41, 56, 8, 25, 43, 62, 18, 39, 61, 20, 44 //
];

final keccakPiln = [
  10, 7, 11, 17, 18, 3, 5, 16, 8, 21, 24, 4, //
  15, 23, 19, 13, 12, 2, 20, 14, 22, 9, 6, 1 //
];

const KECCAK_ROUNDS = 24;
const HASH_DATA_AREA = 136;

int _logicalShiftRight(int val, int n) => (val >> n) & ~(-1 << (64 - n));

int _rotl64(int x, int y) {
  return ((x << y) | _logicalShiftRight(x, (64 - y)));
}

void _keccakf(Uint64List st, [int rounds = KECCAK_ROUNDS]) {
  int t;
  Uint64List bc = Uint64List(5);

  for (int round = 0; round < rounds; round++) {
    // Theta
    for (int i = 0; i < 5; i++) {
      bc[i] = st[i] ^ st[i + 5] ^ st[i + 10] ^ st[i + 15] ^ st[i + 20];
    }

    for (int i = 0; i < 5; i++) {
      t = bc[(i + 4) % 5] ^ _rotl64(bc[(i + 1) % 5], 1);
      for (int j = 0; j < 25; j += 5) {
        st[j + i] ^= t;
      }
    }

    // Rho Pi
    t = st[1];
    for (int i = 0; i < 24; i++) {
      int j = keccakPiln[i];
      bc[0] = st[j];
      st[j] = _rotl64(t, keccakRotc[i]);
      t = bc[0];
    }

    // Chi
    for (int j = 0; j < 25; j += 5) {
      for (int i = 0; i < 5; i++) {
        bc[i] = st[j + i];
      }
      for (int i = 0; i < 5; i++) {
        st[j + i] ^= (~bc[(i + 1) % 5]) & bc[(i + 2) % 5];
      }
    }

    // Iota
    st[0] ^= keccakRoundConstants[round];
  }
}

// Compute a hash of length outputSize from input
Uint8List _keccak(Uint8List input, int outputSize) {
  Uint64List st = Uint64List(25);
  Uint8List temp = Uint8List(144);
  ByteData inp = input.buffer.asByteData();

  int inlen = input.length;
  int offset = 0;

  int rsiz, rsizw;

  rsiz = st.lengthInBytes == outputSize ? HASH_DATA_AREA : 200 - 2 * outputSize;
  rsizw = rsiz ~/ 8;

  for (; inlen >= rsiz; inlen -= rsiz, offset += rsiz) {
    for (int i = 0; i < rsizw; i++) {
      st[i] ^= inp.getUint64(offset + (i * 8), Endian.host);
    }
    _keccakf(st, KECCAK_ROUNDS);
  }

  for (int i = 0; i < inlen; i++) {
    temp[i] = input[offset + i];
  }
  temp[inlen++] = 1;
  for (int i = 0; i < rsiz - inlen; i++) {
    temp[inlen + i] = 0;
  }
  temp[rsiz - 1] |= 0x80;

  ByteData tempData = temp.buffer.asByteData();
  for (int i = 0; i < rsizw; i++) {
    st[i] ^= tempData.getUint64(i * 8, Endian.host);
  }

  _keccakf(st, KECCAK_ROUNDS);

  Uint8List output = st.buffer.asUint8List(0, outputSize);

  return output;
}

/// Hashes the given input with keccak, into an output hash of 200 bytes.
Uint8List keccak1600(Uint8List input) {
  return _keccak(input, 200);
}

/// Hashes the given input with keccak, into an output hash of 32 bytes.
/// Copies outputLength bytes of the output and returns it. Output
/// length cannot be larger than 32.
Uint8List keccak(Uint8List input, [int outputLength = 32]) {
  if (outputLength > 32) {
    throw ArgumentError("Output length must be 32 bytes or less!");
  }

  Uint8List result = _keccak(input, 32);

  Uint8List output = Uint8List(outputLength);

  for (int i = 0; i < min(outputLength, 32); i++) {
    output[i] = result[i];
  }

  return output;
}
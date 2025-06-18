import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class CPK {
  /// Helper function to convert a dynamic value to a consistent byte representation
  /// for hashing. This is critical to ensure that different data types or null values
  /// do not produce the same hash by accident (e.g., int 0 vs. null).
  /// Each type gets a unique prefix byte.
  static List<int> toBytes(dynamic value) {
    final bytesBuilder = BytesBuilder();

    if (value == null) {
      // Prefix for null (0x00), followed by a unique null identifier byte (0xFF).
      // This ensures null values consistently hash differently from non-null values.
      bytesBuilder.addByte(0x00); // Type identifier for null
      bytesBuilder.addByte(0xFF); // Null marker
    } else if (value is int) {
      // Prefix for int (0x01), then convert the integer to 64-bit big-endian bytes.
      bytesBuilder.addByte(0x01); // Type identifier for int
      final data = ByteData(8); // Allocate 8 bytes for a 64-bit integer
      data.setInt64(
        0,
        value,
        Endian.big,
      ); // Write the integer in big-endian format
      bytesBuilder.add(data.buffer.asUint8List()); // Add the bytes
    } else if (value is double) {
      // Prefix for double (0x02), then convert the double to 64-bit big-endian bytes (IEEE 754).
      bytesBuilder.addByte(0x02); // Type identifier for double
      final data = ByteData(8); // Allocate 8 bytes for a 64-bit double
      data.setFloat64(
        0,
        value,
        Endian.big,
      ); // Write the double in big-endian format
      bytesBuilder.add(data.buffer.asUint8List()); // Add the bytes
    } else if (value is String) {
      // Prefix for String (0x03), then encode the string as UTF-8 bytes.
      bytesBuilder.addByte(0x03); // Type identifier for String
      bytesBuilder.add(utf8.encode(value)); // Encode and add string bytes
    } else if (value is bool) {
      // Prefix for bool (0x04), then 0x00 for false, 0x01 for true.
      bytesBuilder.addByte(0x04); // Type identifier for bool
      bytesBuilder.addByte(
        value ? 0x01 : 0x00,
      ); // Add byte based on boolean value
    } else {
      // Throw an error for unsupported types. This helps catch unexpected data
      // that should not be part of the composite primary key.
      throw ArgumentError(
        'Unsupported type for hashing: ${value.runtimeType}. '
        'Only int, double, String, and bool (including null) are supported.',
      );
    }
    return bytesBuilder.toBytes(); // Return the accumulated bytes
  }

  static List<int> encode7Bit(List<int> inputBytes) {
    final output = BytesBuilder();
    int bitBuffer = 0;
    int bitsInBuffer = 0;

    for (int byte in inputBytes) {
      // Add 8 bits from the input byte to the buffer
      bitBuffer |= (byte << bitsInBuffer);
      bitsInBuffer += 8;

      // While there are enough bits to extract a 7-bit chunk
      while (bitsInBuffer >= 7) {
        // Extract the 7-bit chunk
        int chunk = bitBuffer & 0x7F; // Get the lowest 7 bits

        // Set the MSB to 1 to ensure the value is in 0x80-0xFF range
        output.addByte(chunk | 0x80);

        // Remove the 7 bits from the buffer
        bitBuffer >>= 7;
        bitsInBuffer -= 7;
      }
    }

    // Handle any remaining bits in the buffer (less than 7)
    if (bitsInBuffer > 0) {
      output.addByte(
        (bitBuffer & 0x7F) | 0x80,
      ); // Ensure MSB is 1 for the last chunk
    }

    // Ensure the output is exactly 37 bytes for 256 input bits.
    // This padding might be necessary if the final chunk is all zeros
    // or if the exact bit-packing doesn't naturally result in 37 bytes.
    // A correct implementation needs to handle trailing zeros and padding meticulously.
    // For 256 bits, ceil(256/7) is 37. So the output should be 37 bytes.
    // The current loop might produce fewer if the last few bits are zero.
    // A more robust implementation would use a loop that ensures 37 bytes are always output.
    while (output.length < 37) {
      // Pad if less than expected 37 bytes
      output.addByte(0x80); // Pad with a 'safe' zero-equivalent value
    }

    return output.toBytes();
  }

  static String calculateCPK(List<dynamic> data) {
    final sha256Hasher = Sha256().toSync().newHashSink();
    for (final chunk in data)  {
      sha256Hasher.add(toBytes(chunk));
    }

    sha256Hasher.close();
    return String.fromCharCodes(encode7Bit(sha256Hasher.hashSync().bytes));
  }
}

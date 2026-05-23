// import 'dart:async';
// import 'dart:convert';
// import 'dart:isolate';
// import 'dart:typed_data';
// import 'package:blockchain_utils/hex/hex.dart';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/services.dart';
// import 'package:tejory/objectbox.g.dart';
// import 'package:tejory/objectbox/objectbox.dart';
// import 'package:tejory/singleton.dart';
// import 'package:tejory/updates/update.dart';
// import 'package:tejory/updates/update_progress.dart';
// import 'package:http/http.dart' as http;

// class PoRCheck extends Update {
//   Isolate? _isolate;
//   final _receivePort = ReceivePort();
//   late SendPort _sendPort;

//   @override
//   String name() {
//     return "Proof-of-Reserves Audit";
//   }

//   @override
//   Future<bool> required() async {
//     return true;
//   }

//   @override
//   Future<void> start() async {
//     status = UpdateStatus.working;
//     // Listen for messages from the isolate
//     _receivePort.listen((message) {
//       print("PoRCheck: message from isolate ${message}");
//       if (message is UpdateProgress) {
//         streamController.add(message);

//         if (message.done) {
//           stop();
//           status =
//               (message.ex == null)
//                   ? UpdateStatus.successful
//                   : UpdateStatus.error;
//         }
//       } else if (message is SendPort) {
//         _sendPort = message;
//         final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
//         Map<String, dynamic> msg = {
//           "token": rootIsolateToken,
//           "box": Singleton.getObjectBoxDB().getStore().reference,
//         };
//         _sendPort.send(msg);
//       } else {
//         print(
//           "PoRCheck: ERROR: unknown message type ${message.runtimeType}. ${message}",
//         );
//       }
//     });

//     // Spawn the new isolate
//     _isolate = await Isolate.spawn(
//       worker,
//       _receivePort.sendPort,
//       onError: _receivePort.sendPort,
//       onExit: _receivePort.sendPort,
//     );
//   }

//   static void worker(SendPort sendPort) {
//     print("PoRCheck: isolate stared");
//     final _receivePort = ReceivePort();
//     sendPort.send(_receivePort.sendPort);
//     print("PoRCheck: isolate port sent");
//     ObjectBox? box;

//     _receivePort.listen((message) async {
//       try {
//         print("PoRCheck: isolate received message ${message}");
//         if (message is Map<String, dynamic>) {
//           BackgroundIsolateBinaryMessenger.ensureInitialized(message["token"]);
//           await Singleton.initObjectBoxDB(fromBytes: message["box"]);

//           box = Singleton.getObjectBoxDB();
//         }

//         if (box == null) {
//           print("PoRCheck: DB is not initialized");
//           sendPort.send(
//             UpdateProgress(
//               0,
//               done: true,
//               message: "PoRCheck: DB is not initialized",
//               ex: Exception("PoRCheck: DB is not initialized"),
//             ),
//           );
//           return;
//         }

//         sendPort.send(
//           UpdateProgress(
//             0.05,
//             done: false,
//             message: "PoRCheck: downloading merkle tree data",
//             ex: null,
//           ),
//         );

//         String date = DateTime.now().toUtc().toIso8601String();
//         date = date.substring(0, date.indexOf("T"));

//         final key =
//             box!.keyBox
//                 .query(Key_.path.equals("m/9011'/0"))
//                 .build()
//                 .findFirst();

//         if (key == null || key.pubKey == null) {
//           sendPort.send(
//             UpdateProgress(
//               1.0,
//               done: true,
//               message: "PoRCheck: LN is not initialized yet",
//               ex: null,
//             ),
//           );
//           return;
//         }

//         final lnPubLey = key.pubKey!;

//         var URL = Uri.parse("https://ln.tejory.io/api/por/$date/$lnPubLey/");
//         http.Response response;

//         try {
//           response = await http.get(URL).timeout(Duration(seconds: 5));
//         } catch (e) {
//           sendPort.send(
//             UpdateProgress(
//               1.0,
//               done: true,
//               message:
//                   "PoRCheck: failed to download merkle tree data. Please check your connection",
//               ex: null,
//             ),
//           );
//           return;
//         }

//         sendPort.send(
//           UpdateProgress(
//             0.5,
//             done: false,
//             message: "PoRCheck: download merkle tree data",
//             ex: null,
//           ),
//         );

//         final Map<String, dynamic> proofData = jsonDecode(response.body);
//         final balance =
//             box!.balanceBox.query(Balance_.coin.equals(4)).build().findFirst();
//         if (balance == null) {
//           sendPort.send(
//             UpdateProgress(
//               1.0,
//               done: true,
//               message:
//                   "PoRCheck: failed to download merkle tree data. Please check your connection",
//               ex: null,
//             ),
//           );
//           return;
//         }
//         final bool isValid = await verifyMerkleProof(
//           nonce: date,
//           pubkeyHex: lnPubLey,
//           balanceFromSync: balance.coinBalance!,
//           proofData: proofData,
//           // expectedMerkleRootHex: expectedPublicRootHex,
//         );

//         print("PoRCheck: isValid=$isValid");
//         // await Future.delayed(Dura)

//         sendPort.send(
//           UpdateProgress(
//             1.0,
//             done: true,
//             message: "PoRCheck: Merkle tree verified successfully",
//             ex: null,
//           ),
//         );
//       } catch (e) {
//         sendPort.send(
//           UpdateProgress(
//             1.0,
//             done: true,
//             message: "PoRCheck: Error. ${e.toString()}",
//             ex: Exception(e.toString()),
//           ),
//         );
//       }
//     });
//   }

//   void stop() {
//     if (_isolate != null) {
//       _isolate?.kill(priority: Isolate.immediate);
//       _isolate = null;
//       _receivePort.close();
//       streamController.close(); // Close the stream controller
//       doneCompleter.complete();
//       print("PoRCheck: Isolate stopped.");
//     }
//   }

//   @override
//   UpdateStatus getStatus() {
//     return status;
//   }

//   // This function contains the core cryptographic verification logic.
//   static Future<bool> verifyMerkleProof({
//     required String nonce,
//     required String pubkeyHex,
//     required int balanceFromSync,
//     required Map<String, dynamic> proofData,
//     // required String expectedMerkleRootHex,
//   }) async {
//     // --- Step A: Extract data from the server's response ---
//     final String expectedMerkleRootHex = proofData["merkle_root"];
//     final int proofIndex = proofData['index'];
//     final List<String> proofPath = List<String>.from(proofData['path']);
//     final String serverLeafHashHex = proofData['leaf_hash'];
//     // The server doesn't send the balance in our final API design,
//     // but if it did, you would get it here. We'll use the client's synced balance.

//     // --- Step B: Calculate our own leaf hash locally ---
//     // This allows us to verify the balance the server used is correct.
//     final Uint8List pubkeyBytes = Uint8List.fromList(hex.decode(pubkeyHex));
//     final Uint8List balanceBytes = ByteData(8).buffer.asUint8List();
//     balanceBytes.buffer.asByteData().setUint64(
//       0,
//       balanceFromSync,
//       Endian.little,
//     );

//     final List<int> leafData = [...pubkeyBytes, ...balanceBytes];

//     final hmac = Hmac(sha256, utf8.encode(nonce));
//     final Digest localLeafDigest = hmac.convert(leafData);
//     final String localLeafHashHex = hex.encode(localLeafDigest.bytes);

//     // Sanity check: Does the hash the server used match the hash for our balance?
//     if (localLeafHashHex != serverLeafHashHex) {
//       print(
//         "CRITICAL: Server's leaf hash does not match our calculated hash. The balance may be incorrect.",
//       );
//       // In a real app, you might want to throw a specific error here.
//       // For this example, we proceed with the server's hash, but the final proof will fail.
//     }

//     // The verification must proceed with the hash from the server's proof.
//     Uint8List currentHash = Uint8List.fromList(hex.decode(serverLeafHashHex));
//     int currentIndex = proofIndex;

//     // --- Step C: Walk up the tree, hashing at each level ---
//     for (final String siblingHashHex in proofPath) {
//       final Uint8List siblingHash = Uint8List.fromList(
//         hex.decode(siblingHashHex),
//       );
//       List<int> concatenated;

//       if (currentIndex % 2 == 0) {
//         // Even index: current node is on the left
//         concatenated = [...currentHash, ...siblingHash];
//       } else {
//         // Odd index: current node is on the right
//         concatenated = [...siblingHash, ...currentHash];
//       }

//       // Hash the concatenated data to get the parent hash
//       currentHash = Uint8List.fromList(sha256.convert(concatenated).bytes);

//       // Move up to the next level
//       currentIndex = currentIndex ~/ 2; // Integer division
//     }

//     // --- Step D: Compare the final calculated root with the public root ---
//     final String finalCalculatedRootHex = hex.encode(currentHash);

//     print("Final Calculated Root: $finalCalculatedRootHex");
//     print("Expected Public Root:  $expectedMerkleRootHex");

//     return finalCalculatedRootHex == expectedMerkleRootHex;
//   }
// }

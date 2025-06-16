import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:tejory/box_models.g.dart';
import 'package:tejory/objectbox/balance.dart';
import 'package:tejory/objectbox/block.dart';
import 'package:tejory/objectbox/coin.dart';
import 'package:tejory/objectbox/data_version.dart';
import 'package:tejory/objectbox/key.dart';
import 'package:tejory/objectbox/lp.dart';
import 'package:tejory/objectbox/next_key.dart';
import 'package:tejory/objectbox/tx.dart';
import 'package:tejory/objectbox/wallet_db.dart';

import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/updates/update.dart';
import 'package:tejory/updates/update_progress.dart';

class CPKCalculation extends Update {
  Isolate? _isolate;
  final _receivePort = ReceivePort();
  late SendPort _sendPort;

  @override
  String name() {
    return "CPK Calculation";
  }

  @override
  Future<bool> required() async {
    var box = Singleton.getObjectBoxDB();

    if (box.walletDBBox.count() != 0) {
      if (box.walletDBBox.query().build().findFirst()!.cpk == null)
      return true;
    }
    return false;
  }

  @override
  Future<void> start() async {
    status = UpdateStatus.working;
    // Listen for messages from the isolate
    _receivePort.listen((message) {
      if (message is UpdateProgress) {
        streamController.add(message);

        if (message.done) {
          stop();
          status =
              (message.ex == null)
                  ? UpdateStatus.successful
                  : UpdateStatus.error;
        }
      } else if (message is SendPort) {
        _sendPort = message;
        final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
        Map<String, dynamic> msg = {
          "token": rootIsolateToken,
          "box": Singleton.getObjectBoxDB().getStore().reference,
        };
        _sendPort.send(msg);
      } else {
        print(
          "CPKCalculation: ERROR: unknown message type ${message.runtimeType}. ${message}",
        );
      }
    });

    // Spawn the new isolate
    _isolate = await Isolate.spawn(
      worker,
      _receivePort.sendPort,
      onError: _receivePort.sendPort,
      onExit: _receivePort.sendPort,
    );
  }

  static void worker(SendPort sendPort) {
    Stopwatch watch = Stopwatch()..start();
    print("CPKCalculation: isolate stared");
    final _receivePort = ReceivePort();
    sendPort.send(_receivePort.sendPort);
    print("CPKCalculation: isolate port sent");
    ObjectBox? box;

    _receivePort.listen((message) async {
      try {
        print("CPKCalculation: isolate received message ${message}");
        if (message is Map<String, dynamic>) {
          BackgroundIsolateBinaryMessenger.ensureInitialized(message["token"]);
          await Singleton.initObjectBoxDB(fromBytes: message["box"]);

          box = Singleton.getObjectBoxDB();
        }

        if (box == null) {
          print("CPKCalculation: DB is not initialized");
          sendPort.send(
            UpdateProgress(
              0,
              done: true,
              message: "CPKCalculation: DB is not initialized",
              ex: Exception("CPKCalculation: DB is not initialized"),
            ),
          );
          return;
        }

        print("CPKCalculation: db initialized");

        List<CPKTask> tablesList = [
          CPKTask<Balance>(
            box!.balanceBox,
            Models.balance,
            "balance",
          ),
          CPKTask<Block>(
            box!.blockBox,
            Models.block,
            "block",
          ),
          CPKTask<Coin>(
            box!.coinBox,
            Models.coin,
            "coin",
          ),
          CPKTask<DataVersion>(
            box!.dataVersionBox,
            Models.dataVersion,
            "dataVersion",
          ),
          CPKTask<Key>(
            box!.keyBox,
            Models.key,
            "key",
          ),
          CPKTask<LP>(box!.lPBox, Models.lP, "lp"),
          CPKTask<NextKey>(
            box!.nextKeyBox,
            Models.nextKey,
            "nextKey",
          ),
          CPKTask<TxDB>(
            box!.txDBBox,
            Models.txDB,
            "txDB",
          ),
          CPKTask<WalletDB>(
            box!.walletDBBox,
            Models.walletDB,
            "walletDB",
          ),
        ];

        print("CPKCalculation: list prepared");

        int tableCounter = 0;
        for (final table in tablesList) {
          final records = table.getAll();
          for (int i=0; i<records.length; i++) {
            records[i].cpk = records[i].getCPK_();
          }

          table.box.putMany(records);

          tableCounter++;

          double progress = (tableCounter) / tablesList.length;
          print(
            "CPKCalculation: Done with ${tableCounter} progress ${(progress * 100)}%",
          );
          // send message
          sendPort.send(
            UpdateProgress(
              progress,
              done: tableCounter == tablesList.length,
              message: "CPKCalculation: Completed ${table.name}",
              ex: null,
            ),
          );
        }
        print("CPKCalculation: Done completed in ${watch.elapsedMilliseconds}ms");
      } catch (e) {
        print("CPKCalculation: ERROR. $e");
        sendPort.send(
          UpdateProgress(
            1.0,
            done: true,
            message: "CPKCalculation: Error. ${e.toString()}",
            ex: Exception(e.toString()),
          ),
        );
      }
    });
  }

  void stop() {
    if (_isolate != null) {
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
      _receivePort.close();
      streamController.close(); // Close the stream controller
      doneCompleter.complete();
      print("CPKCalculation: Isolate stopped.");
    }
  }

  @override
  UpdateStatus getStatus() {
    return status;
  }
}

class CPKTask<T> {
  Box<T> box;
  BaseBoxModel<T, dynamic> model;
  String name;

  CPKTask(this.box, this.model, this.name);

  List<T> getAll() {
    return box.getAll();
  }
}

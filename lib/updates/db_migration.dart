import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:tejory/box_models.g.dart';
import 'package:tejory/collections/balance.dart';
import 'package:tejory/collections/block.dart';
import 'package:tejory/collections/coin.dart';
import 'package:tejory/collections/data_version.dart';
import 'package:tejory/collections/key.dart';
import 'package:tejory/collections/lp.dart';
import 'package:tejory/collections/next_key.dart';
import 'package:tejory/collections/tx.dart';
import 'package:tejory/collections/wallet_db.dart';

import 'package:tejory/objectbox/balance.dart' as boxmodel;
import 'package:tejory/objectbox/block.dart' as boxmodel;
import 'package:tejory/objectbox/coin.dart' as boxmodel;
import 'package:tejory/objectbox/data_version.dart' as boxmodel;
import 'package:tejory/objectbox/key.dart' as boxmodel;
import 'package:tejory/objectbox/lp.dart' as boxmodel;
import 'package:tejory/objectbox/next_key.dart' as boxmodel;
import 'package:tejory/objectbox/tx.dart' as boxmodel;
import 'package:tejory/objectbox/wallet_db.dart' as boxmodel;

import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/updates/update.dart';
import 'package:tejory/updates/update_progress.dart';

class DBMigration extends Update {
  Isolate? _isolate;
  final _receivePort = ReceivePort();
  late SendPort _sendPort;

  @override
  String name() {
    return "DB Migration";
  }

  @override
  Future<bool> required() async {
    var isar = Singleton.getDB();
    var box = Singleton.getObjectBoxDB();

    if (await isar.walletDBs.countSync() != 0 && box.walletDBBox.count() == 0) {
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
          "DBMigration: ERROR: unknown message type ${message.runtimeType}. ${message}",
        );
      }
    });

    // Spawn the new isolate
    _isolate = await Isolate.spawn(
      migrationWorker,
      _receivePort.sendPort,
      onError: _receivePort.sendPort,
      onExit: _receivePort.sendPort,
    );
  }

  static void migrationWorker(SendPort sendPort) {
    Stopwatch watch = Stopwatch()..start();
    print("DBMigration: isolate stared");
    final _receivePort = ReceivePort();
    sendPort.send(_receivePort.sendPort);
    print("DBMigration: isolate port sent");
    Isar? isar;
    ObjectBox? box;

    _receivePort.listen((message) async {
      try {
        print("DBMigration: isolate received message ${message}");
        if (message is Map<String, dynamic>) {
          BackgroundIsolateBinaryMessenger.ensureInitialized(message["token"]);
          await Singleton.initDB();
          await Singleton.initObjectBoxDB(fromBytes: message["box"]);

          isar = Singleton.getDB();
          box = Singleton.getObjectBoxDB();
        }

        if (isar == null || box == null) {
          print("DBMigration: DB is not initialized");
          sendPort.send(
            UpdateProgress(
              0,
              done: true,
              message: "DBMigration: DB is not initialized",
              ex: Exception("DBMigration: DB is not initialized"),
            ),
          );
          return;
        }

        print("DBMigration: db initialized");
        List<MigrationTask> migrationList = [
          MigrationTask<boxmodel.Balance>(
            isar!.balances,
            box!.balanceBox,
            Models.balance,
            "balance",
          ),
          MigrationTask<boxmodel.Block>(
            isar!.blocks,
            box!.blockBox,
            Models.block,
            "block",
          ),
          MigrationTask<boxmodel.Coin>(
            isar!.coins,
            box!.coinBox,
            Models.coin,
            "coin",
          ),
          MigrationTask<boxmodel.DataVersion>(
            isar!.dataVersions,
            box!.dataVersionBox,
            Models.dataVersion,
            "dataVersion",
          ),
          MigrationTask<boxmodel.Key>(
            isar!.keys,
            box!.keyBox,
            Models.key,
            "key",
          ),
          MigrationTask<boxmodel.LP>(isar!.lPs, box!.lPBox, Models.lP, "lp"),
          MigrationTask<boxmodel.NextKey>(
            isar!.nextKeys,
            box!.nextKeyBox,
            Models.nextKey,
            "nextKey",
          ),
          MigrationTask<boxmodel.TxDB>(
            isar!.txDBs,
            box!.txDBBox,
            Models.txDB,
            "txDB",
          ),
          MigrationTask<boxmodel.WalletDB>(
            isar!.walletDBs,
            box!.walletDBBox,
            Models.walletDB,
            "walletDB",
          ),
        ];

        print("DBMigration: list prepared");

        int tableCounter = 0;
        for (final entry in migrationList) {
          // final Type type = entry.boxType;
          print("DBMigration: reading number ${tableCounter + 1}");
          var srcRecords = entry.isarCollection.where().findAllSync();

          print("DBMigration: converting number ${tableCounter + 1}");
          final dstRecords = entry.fromIsar(srcRecords);

          print("DBMigration: storing number ${tableCounter + 1}");
          entry.box.putMany(dstRecords, mode: PutMode.put);

          // send message
          tableCounter++;

          double progress = (tableCounter) / migrationList.length;
          print(
            "DBMigration: Done with ${tableCounter} progress ${(progress * 100)}%",
          );
          sendPort.send(
            UpdateProgress(
              progress,
              done: tableCounter == migrationList.length,
              message: "DBMigration: Completed ${entry.name}",
              ex: null,
            ),
          );
        }
        print("DBMigration: Done completed in ${watch.elapsedMilliseconds}ms");
      } catch (e) {
        sendPort.send(
          UpdateProgress(
            1.0,
            done: true,
            message: "DBMigration: Error. ${e.toString()}",
            ex: e as Exception,
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
      print("DBMigration: Isolate stopped.");
    }
  }

  @override
  UpdateStatus getStatus() {
    return status;
  }
}

class MigrationTask<T> {
  IsarCollection isarCollection;
  Box box;
  BaseBoxModel model;
  String name;

  MigrationTask(this.isarCollection, this.box, this.model, this.name);

  List<T> fromIsar(List<dynamic> val) {
    return val.map<T>((record) => model.fromIsar(record)).toList();
  }
}

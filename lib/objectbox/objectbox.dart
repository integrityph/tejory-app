import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/balance.dart';
import 'package:path/path.dart' as p;
import 'package:tejory/objectbox/block.dart';
import 'package:objectbox/objectbox.dart';
import 'package:tejory/objectbox/coin.dart';
import 'package:tejory/objectbox/data_version.dart';
import 'package:tejory/objectbox/key.dart';
import 'package:tejory/objectbox/lp.dart';
import 'package:tejory/objectbox/next_key.dart';
import 'package:tejory/objectbox/tx.dart';
import 'package:tejory/objectbox/wallet_db.dart';

class ObjectBox {
  // The Store of this app.
  late Store _store;

  // A Box of notes.
  late final Box<Balance> balanceBox;
  late final Box<Block> blockBox;
  late final Box<Coin> coinBox;
  late final Box<DataVersion> dataVersionBox;
  late final Box<Key> keyBox;
  late final Box<LP> lPBox;
  late final Box<NextKey> nextKeyBox;
  late final Box<TxDB> txDBBox;
  late final Box<WalletDB> walletDBBox;

  ObjectBox._create(this._store) {
    // All models should be here
    balanceBox = Box<Balance>(_store);
    blockBox = Box<Block>(_store);
    coinBox = Box<Coin>(_store);
    dataVersionBox = Box<DataVersion>(_store);
    keyBox = Box<Key>(_store);
    lPBox = Box<LP>(_store);
    nextKeyBox = Box<NextKey>(_store);
    txDBBox = Box<TxDB>(_store);
    walletDBBox = Box<WalletDB>(_store);
  }

  Store getStore() {
    return _store;
  }


  static Future<void> deleteDbFiles() async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      Directory dbDir = Directory(docDir.path + '/obx-db');
      if (dbDir.existsSync()) {
        dbDir.delete(recursive: true);
      }
    } catch(e) {}
  }

  // Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create({ByteData? fromBytes}) async {
    Store store;
    if (fromBytes != null) {
      store = Store.fromReference(getObjectBoxModel(), fromBytes);
    } else {
      store = await openStore(
        directory: p.join(
          (await getApplicationDocumentsDirectory()).path,
          "obx-db",
        ),
      );
    }

    return ObjectBox._create(store);
  }
}

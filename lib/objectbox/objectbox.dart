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
  late final Store _store;

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

  // Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final store = await openStore(
      directory: p.join(
        (await getApplicationDocumentsDirectory()).path,
        "obx-db",
      ),
    );
    return ObjectBox._create(store);
  }

  Stream<List<Balance>> getBalances() {
    // Query for all notes, sorted by their date.
    // https://docs.objectbox.io/queries
    final builder = balanceBox.query().order(
      Balance_.id,
      flags: Order.descending,
    );
    // Build and watch the query,
    // set triggerImmediately to emit the query immediately on listen.
    return builder
        .watch(triggerImmediately: true)
        // Map it to a list of notes to be used by a StreamBuilder.
        .map((query) => query.find());
  }

  /// Add a note.
  ///
  /// To avoid frame drops, run ObjectBox operations that take longer than a
  /// few milliseconds, e.g. putting many objects, asynchronously.
  /// For this example only a single object is put which would also be fine if
  /// done using [Box.put].
  Future<void> addBalance(String text) => balanceBox.putAsync(Balance());

  Future<void> removeBalance(int id) => balanceBox.removeAsync(id);
}

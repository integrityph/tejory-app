// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tx.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension TxDBBoxModelHelpers on TxDB {
  Future<int?> save() async {
    return TxDBModel().upsert(this);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class TxDBModel extends BaseBoxModel<TxDB, isar.TxDB> {
  const TxDBModel();

  Future<List<TxDB>?> find({
    Condition<TxDB>? q,
    QueryProperty<TxDB, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.txDBBox.query(q);
    if (order != null) {
      queryBuilder = queryBuilder.order(
        order,
        flags: ascending ? 0 : Order.descending,
      );
    }
    final query = queryBuilder.build();
    if (limit != null) {
      query.limit = limit;
    }
    try {
      final result = await query.findAsync();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: TxDB.find ${e}");
      return null;
    }
  }

  Future<int?> count({Condition<TxDB>? q}) async {
    final objectbox = Singleton.getObjectBoxDB();
    final query = objectbox.txDBBox.query(q).build();
    try {
      return query.count();
    } catch (e) {
      print("ERROR: TxDB.count ${e}");
      return null;
    } finally {
      query.close();
    }
  }

  Future<TxDB?> getById(int id) async {
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.txDBBox.getAsync(id);
  }

  Condition<TxDB> uniqueCondition(int id) {
    return TxDB_.id.equals(id);
  }

  Future<TxDB?> getUnique(int id) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.txDBBox.query(uniqueCondition(id)).build();
    final result = await query.findFirstAsync();
    query.close();
    return result;
  }

  Future<int> upsert(TxDB txDB) async {
    final box = Singleton.getObjectBoxDB();

    if (txDB.id != 0) {
      return box.txDBBox.putAsync(txDB);
    }

    return box.getStore().runInTransactionAsync(TxMode.write, (
      Store store,
      TxDB txDB,
    ) {
      final query = box.txDBBox.query(uniqueCondition(txDB.id)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        txDB.id = existingId[0];
      }

      return store.box<TxDB>().put(txDB);
    }, txDB);
  }

  TxDB fromIsar(isar.TxDB src) {
    TxDB val = TxDB();
    val.id = src.id;
    val.wallet = src.wallet;
    val.coin = src.coin;
    val.time = src.time;
    val.amount = src.amount;
    val.usdAmount = src.usdAmount;
    val.isDeposit = src.isDeposit;
    val.hash = src.hash;
    val.spendingTxHash = src.spendingTxHash;
    val.blockHash = src.blockHash;
    val.fee = src.fee;
    val.spent = src.spent;
    val.confirmed = src.confirmed;
    val.verified = src.verified;
    val.failed = src.failed;
    val.lockingScript = src.lockingScript;
    val.lockingScriptType = src.lockingScriptType;
    val.hdPath = src.hdPath;
    val.outputIndex = src.outputIndex;

    return val;
  }
}

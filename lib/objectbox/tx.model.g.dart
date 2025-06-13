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
      final result = query.find();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: TxDB.find ${e}");
      return null;
    }
  }

  Future<int?> delete({
    Condition<TxDB>? q,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.txDBBox.query(q);
    final query = queryBuilder.build();
    try {
      final result = query.remove();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: TxDB.delete ${e}");
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
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.txDBBox.get(id);
  }

  Condition<TxDB> uniqueCondition(int? coin, String? hash, int? outputIndex) {
    return ((coin == null) ? TxDB_.coin.isNull() : TxDB_.coin.equals(coin)) &
        ((hash == null) ? TxDB_.hash.isNull() : TxDB_.hash.equals(hash)) &
        ((outputIndex == null)
            ? TxDB_.outputIndex.isNull()
            : TxDB_.outputIndex.equals(outputIndex));
  }

  Future<TxDB?> getUnique(int? coin, String? hash, int? outputIndex) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query =
        box.txDBBox.query(uniqueCondition(coin, hash, outputIndex)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Future<int> upsert(TxDB txDB) async {
    final box = Singleton.getObjectBoxDB();

    if (txDB.id != 0) {
      return box.txDBBox.put(txDB);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query = box.txDBBox
          .query(uniqueCondition(txDB.coin, txDB.hash, txDB.outputIndex))
          .build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        txDB.id = existingId[0];
      }

      return box.txDBBox.put(txDB);
    });
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

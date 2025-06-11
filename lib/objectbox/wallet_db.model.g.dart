// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_db.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension WalletDBBoxModelHelpers on WalletDB {
  Future<int?> save() async {
    return WalletDBModel().upsert(this);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class WalletDBModel {
  const WalletDBModel();

  Future<List<WalletDB>?> find({
    Condition<WalletDB>? q,
    QueryProperty<WalletDB, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.walletDBBox.query(q);
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
      print("ERROR: WalletDB.find ${e}");
      return null;
    }
  }

  Future<int?> count({Condition<WalletDB>? q}) async {
    final objectbox = Singleton.getObjectBoxDB();
    final query = objectbox.walletDBBox.query(q).build();
    try {
      return query.count();
    } catch (e) {
      print("ERROR: WalletDB.count ${e}");
      return null;
    } finally {
      query.close();
    }
  }

  Future<WalletDB?> getById(int id) async {
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.walletDBBox.getAsync(id);
  }

  Condition<WalletDB> uniqueCondition(int id) {
    return WalletDB_.id.equals(id);
  }

  Future<WalletDB?> getUnique(int id) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.walletDBBox.query(uniqueCondition(id)).build();
    final result = await query.findFirstAsync();
    query.close();
    return result;
  }

  Future<int> upsert(WalletDB walletDB) async {
    final box = Singleton.getObjectBoxDB();

    if (walletDB.id != 0) {
      return box.walletDBBox.putAsync(walletDB);
    }

    return box.getStore().runInTransactionAsync(TxMode.write, (
      Store store,
      WalletDB walletDB,
    ) {
      final query = box.walletDBBox.query(uniqueCondition(walletDB.id)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        walletDB.id = existingId[0];
      }

      return store.box<WalletDB>().put(walletDB);
    }, walletDB);
  }
}

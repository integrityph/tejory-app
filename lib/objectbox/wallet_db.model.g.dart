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

class WalletDBModel extends BaseBoxModel<WalletDB, isar.WalletDB> {
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
      final result = query.find();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: WalletDB.find ${e}");
      return null;
    }
  }

  Future<int?> delete({
    Condition<WalletDB>? q,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.walletDBBox.query(q);
    final query = queryBuilder.build();
    try {
      final result = query.remove();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: WalletDB.delete ${e}");
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
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.walletDBBox.get(id);
  }

  Condition<WalletDB> uniqueCondition(int id) {
    return WalletDB_.id.equals(id);
  }

  Future<WalletDB?> getUnique(int id) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.walletDBBox.query(uniqueCondition(id)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Future<int> upsert(WalletDB walletDB) async {
    final box = Singleton.getObjectBoxDB();

    if (walletDB.id != 0) {
      return box.walletDBBox.put(walletDB);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query = box.walletDBBox.query(uniqueCondition(walletDB.id)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        walletDB.id = existingId[0];
      }

      return box.walletDBBox.put(walletDB);
    });
  }

  WalletDB fromIsar(isar.WalletDB src) {
    WalletDB val = WalletDB();
    val.id = src.id;
    val.name = src.name;
    val.type = src.type;
    val.fingerPrint = src.fingerPrint;
    val.extendedPrivKey = src.extendedPrivKey;
    val.easyImport = src.easyImport;
    val.startYear = src.startYear;
    val.serialNumber = src.serialNumber;

    return val;
  }
}

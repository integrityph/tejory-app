// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_db.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension WalletDBBoxModelHelpers on WalletDB {
  int? save() {
    return WalletDBModel().upsert(this);
  }

  String getCPK() {
    return WalletDBModel().calculateCPK(id);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class WalletDBModel extends BaseBoxModel<WalletDB, isar.WalletDB> {
  const WalletDBModel();

  List<WalletDB>? find({
    Condition<WalletDB>? q,
    QueryProperty<WalletDB, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) {
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

  int? delete({
    Condition<WalletDB>? q,
  }) {
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

  int? count({Condition<WalletDB>? q}) {
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

  WalletDB? getById(int id) {
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.walletDBBox.get(id);
  }

  Condition<WalletDB> uniqueConditionMV(int id) {
    return WalletDB_.id.equals(id);
  }

  Condition<WalletDB> uniqueCondition(int id) {
    return WalletDB_.cpk.equals(calculateCPK(id));
  }

  String calculateCPK(int id) {
    final sha256Hasher = Sha256().toSync().newHashSink();
    sha256Hasher.add(CPK.toBytes(id));

    sha256Hasher.close();
    return String.fromCharCodes(CPK.encode7Bit(sha256Hasher.hashSync().bytes));
  }

  WalletDB? getUniqueMV(int id) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.walletDBBox.query(uniqueConditionMV(id)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  WalletDB? getUnique(int id) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.walletDBBox.query(uniqueCondition(id)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  int upsertMV(WalletDB walletDB) {
    final box = Singleton.getObjectBoxDB();

    if (walletDB.id != 0) {
      return box.walletDBBox.put(walletDB);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query =
          box.walletDBBox.query(uniqueConditionMV(walletDB.id)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        walletDB.id = existingId[0];
      }

      return box.walletDBBox.put(walletDB);
    });
  }

  int upsert(WalletDB walletDB) {
    final box = Singleton.getObjectBoxDB();
    walletDB.cpk = walletDB.getCPK();
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

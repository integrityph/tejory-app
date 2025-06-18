// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension KeyBoxModelHelpers on Key {
  int? save() {
    return KeyModel().upsert(this);
  }

  String getCPK() {
    return KeyModel().calculateCPK(wallet, coin, path);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class KeyModel extends BaseBoxModel<Key, isar.Key> {
  const KeyModel();

  List<Key>? find({
    Condition<Key>? q,
    QueryProperty<Key, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.keyBox.query(q);
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
      print("ERROR: Key.find ${e}");
      return null;
    }
  }

  int? delete({
    Condition<Key>? q,
  }) {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.keyBox.query(q);
    final query = queryBuilder.build();
    try {
      final result = query.remove();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: Key.delete ${e}");
      return null;
    }
  }

  int? count({Condition<Key>? q}) {
    final objectbox = Singleton.getObjectBoxDB();
    final query = objectbox.keyBox.query(q).build();
    try {
      return query.count();
    } catch (e) {
      print("ERROR: Key.count ${e}");
      return null;
    } finally {
      query.close();
    }
  }

  Key? getById(int id) {
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.keyBox.get(id);
  }

  Condition<Key> uniqueConditionMV(int? wallet, int? coin, String? path) {
    return ((wallet == null)
            ? Key_.wallet.isNull()
            : Key_.wallet.equals(wallet)) &
        ((coin == null) ? Key_.coin.isNull() : Key_.coin.equals(coin)) &
        ((path == null) ? Key_.path.isNull() : Key_.path.equals(path));
  }

  Condition<Key> uniqueCondition(int? wallet, int? coin, String? path) {
    return Key_.cpk.equals(calculateCPK(wallet, coin, path));
  }

  String calculateCPK(int? wallet, int? coin, String? path) {
    return CPK.calculateCPK([wallet, coin, path]);
  }

  Key? getUniqueMV(int? wallet, int? coin, String? path) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query =
        box.keyBox.query(uniqueConditionMV(wallet, coin, path)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Key? getUnique(int? wallet, int? coin, String? path) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.keyBox.query(uniqueCondition(wallet, coin, path)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  int upsertMV(Key key) {
    final box = Singleton.getObjectBoxDB();

    if (key.id != 0) {
      return box.keyBox.put(key);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query = box.keyBox
          .query(uniqueConditionMV(key.wallet, key.coin, key.path))
          .build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        key.id = existingId[0];
      }

      return box.keyBox.put(key);
    });
  }

  int upsert(Key key) {
    final box = Singleton.getObjectBoxDB();
    key.cpk = key.getCPK();
    if (key.id != 0) {
      return box.keyBox.put(key);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query = box.keyBox
          .query(uniqueCondition(key.wallet, key.coin, key.path))
          .build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        key.id = existingId[0];
      }

      return box.keyBox.put(key);
    });
  }

  Key fromIsar(isar.Key src) {
    Key val = Key();
    val.id = src.id;
    val.wallet = src.wallet;
    val.coin = src.coin;
    val.path = src.path;
    val.pubKey = src.pubKey;
    val.chainCode = src.chainCode;

    return val;
  }
}

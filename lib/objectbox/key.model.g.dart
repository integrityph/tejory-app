// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension KeyBoxModelHelpers on Key {
  Future<int?> save() async {
    return KeyModel().upsert(this);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class KeyModel extends BaseBoxModel<Key, isar.Key> {
  const KeyModel();

  Future<List<Key>?> find({
    Condition<Key>? q,
    QueryProperty<Key, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) async {
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
      final result = await query.findAsync();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: Key.find ${e}");
      return null;
    }
  }

  Future<int?> count({Condition<Key>? q}) async {
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

  Future<Key?> getById(int id) async {
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.keyBox.getAsync(id);
  }

  Condition<Key> uniqueCondition(int? wallet, int? coin, String? path) {
    return ((wallet == null)
            ? Key_.wallet.isNull()
            : Key_.wallet.equals(wallet)) &
        ((coin == null) ? Key_.coin.isNull() : Key_.coin.equals(coin)) &
        ((path == null) ? Key_.path.isNull() : Key_.path.equals(path));
  }

  Future<Key?> getUnique(int? wallet, int? coin, String? path) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.keyBox.query(uniqueCondition(wallet, coin, path)).build();
    final result = await query.findFirstAsync();
    query.close();
    return result;
  }

  Future<int> upsert(Key key) async {
    final box = Singleton.getObjectBoxDB();

    if (key.id != 0) {
      return box.keyBox.putAsync(key);
    }

    return box.getStore().runInTransactionAsync(TxMode.write, (
      Store store,
      Key key,
    ) {
      final query = box.keyBox
          .query(uniqueCondition(key.wallet, key.coin, key.path))
          .build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        key.id = existingId[0];
      }

      return store.box<Key>().put(key);
    }, key);
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

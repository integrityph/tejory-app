// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_key.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension NextKeyBoxModelHelpers on NextKey {
  int? save() {
    return NextKeyModel().upsert(this);
  }

  String getCPK() {
    return NextKeyModel().calculateCPK(wallet, coin, path);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class NextKeyModel extends BaseBoxModel<NextKey, isar.NextKey> {
  const NextKeyModel();

  List<NextKey>? find({
    Condition<NextKey>? q,
    QueryProperty<NextKey, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.nextKeyBox.query(q);
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
      print("ERROR: NextKey.find ${e}");
      return null;
    }
  }

  int? delete({
    Condition<NextKey>? q,
  }) {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.nextKeyBox.query(q);
    final query = queryBuilder.build();
    try {
      final result = query.remove();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: NextKey.delete ${e}");
      return null;
    }
  }

  int? count({Condition<NextKey>? q}) {
    final objectbox = Singleton.getObjectBoxDB();
    final query = objectbox.nextKeyBox.query(q).build();
    try {
      return query.count();
    } catch (e) {
      print("ERROR: NextKey.count ${e}");
      return null;
    } finally {
      query.close();
    }
  }

  NextKey? getById(int id) {
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.nextKeyBox.get(id);
  }

  Condition<NextKey> uniqueConditionMV(int? wallet, int? coin, String? path) {
    return ((wallet == null)
            ? NextKey_.wallet.isNull()
            : NextKey_.wallet.equals(wallet)) &
        ((coin == null) ? NextKey_.coin.isNull() : NextKey_.coin.equals(coin)) &
        ((path == null) ? NextKey_.path.isNull() : NextKey_.path.equals(path));
  }

  Condition<NextKey> uniqueCondition(int? wallet, int? coin, String? path) {
    return NextKey_.cpk.equals(calculateCPK(wallet, coin, path));
  }

  String calculateCPK(int? wallet, int? coin, String? path) {
    return CPK.calculateCPK([wallet, coin, path]);
  }

  NextKey? getUniqueMV(int? wallet, int? coin, String? path) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query =
        box.nextKeyBox.query(uniqueConditionMV(wallet, coin, path)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  NextKey? getUnique(int? wallet, int? coin, String? path) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query =
        box.nextKeyBox.query(uniqueCondition(wallet, coin, path)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  int upsertMV(NextKey nextKey) {
    final box = Singleton.getObjectBoxDB();

    if (nextKey.id != 0) {
      return box.nextKeyBox.put(nextKey);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query = box.nextKeyBox
          .query(uniqueConditionMV(nextKey.wallet, nextKey.coin, nextKey.path))
          .build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        nextKey.id = existingId[0];
      }

      return box.nextKeyBox.put(nextKey);
    });
  }

  int upsert(NextKey nextKey) {
    final box = Singleton.getObjectBoxDB();
    nextKey.cpk = nextKey.getCPK();
    if (nextKey.id != 0) {
      return box.nextKeyBox.put(nextKey);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query = box.nextKeyBox
          .query(uniqueCondition(nextKey.wallet, nextKey.coin, nextKey.path))
          .build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        nextKey.id = existingId[0];
      }

      return box.nextKeyBox.put(nextKey);
    });
  }

  NextKey fromIsar(isar.NextKey src) {
    NextKey val = NextKey();
    val.id = src.id;
    val.wallet = src.wallet;
    val.coin = src.coin;
    val.path = src.path;
    val.nextKey = src.nextKey;

    return val;
  }
}

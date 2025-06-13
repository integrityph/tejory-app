// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_key.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension NextKeyBoxModelHelpers on NextKey {
  Future<int?> save() async {
    return NextKeyModel().upsert(this);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class NextKeyModel extends BaseBoxModel<NextKey, isar.NextKey> {
  const NextKeyModel();

  Future<List<NextKey>?> find({
    Condition<NextKey>? q,
    QueryProperty<NextKey, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) async {
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
      final result = await query.findAsync();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: NextKey.find ${e}");
      return null;
    }
  }

  Future<int?> count({Condition<NextKey>? q}) async {
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

  Future<NextKey?> getById(int id) async {
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.nextKeyBox.getAsync(id);
  }

  Condition<NextKey> uniqueCondition(int? wallet, int? coin, String? path) {
    return ((wallet == null)
            ? NextKey_.wallet.isNull()
            : NextKey_.wallet.equals(wallet)) &
        ((coin == null) ? NextKey_.coin.isNull() : NextKey_.coin.equals(coin)) &
        ((path == null) ? NextKey_.path.isNull() : NextKey_.path.equals(path));
  }

  Future<NextKey?> getUnique(int? wallet, int? coin, String? path) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query =
        box.nextKeyBox.query(uniqueCondition(wallet, coin, path)).build();
    final result = await query.findFirstAsync();
    query.close();
    return result;
  }

  Future<int> upsert(NextKey nextKey) async {
    final box = Singleton.getObjectBoxDB();

    if (nextKey.id != 0) {
      return box.nextKeyBox.putAsync(nextKey);
    }

    return box.getStore().runInTransactionAsync(TxMode.write, (
      Store store,
      NextKey nextKey,
    ) {
      final query = box.nextKeyBox
          .query(uniqueCondition(nextKey.wallet, nextKey.coin, nextKey.path))
          .build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        nextKey.id = existingId[0];
      }

      return store.box<NextKey>().put(nextKey);
    }, nextKey);
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

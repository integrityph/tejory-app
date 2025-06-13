// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lp.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension LPBoxModelHelpers on LP {
  Future<int?> save() async {
    return LPModel().upsert(this);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class LPModel extends BaseBoxModel<LP, isar.LP> {
  const LPModel();

  Future<List<LP>?> find({
    Condition<LP>? q,
    QueryProperty<LP, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.lPBox.query(q);
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
      print("ERROR: LP.find ${e}");
      return null;
    }
  }

  Future<int?> count({Condition<LP>? q}) async {
    final objectbox = Singleton.getObjectBoxDB();
    final query = objectbox.lPBox.query(q).build();
    try {
      return query.count();
    } catch (e) {
      print("ERROR: LP.count ${e}");
      return null;
    } finally {
      query.close();
    }
  }

  Future<LP?> getById(int id) async {
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.lPBox.getAsync(id);
  }

  Condition<LP> uniqueCondition(String? currency0, String? currency1) {
    return ((currency0 == null)
            ? LP_.currency0.isNull()
            : LP_.currency0.equals(currency0)) &
        ((currency1 == null)
            ? LP_.currency1.isNull()
            : LP_.currency1.equals(currency1));
  }

  Future<LP?> getUnique(String? currency0, String? currency1) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query =
        box.lPBox.query(uniqueCondition(currency0, currency1)).build();
    final result = await query.findFirstAsync();
    query.close();
    return result;
  }

  Future<int> upsert(LP lP) async {
    final box = Singleton.getObjectBoxDB();

    if (lP.id != 0) {
      return box.lPBox.putAsync(lP);
    }

    return box.getStore().runInTransactionAsync(TxMode.write, (
      Store store,
      LP lP,
    ) {
      final query =
          box.lPBox.query(uniqueCondition(lP.currency0, lP.currency1)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        lP.id = existingId[0];
      }

      return store.box<LP>().put(lP);
    }, lP);
  }

  LP fromIsar(isar.LP src) {
    LP val = LP();
    val.id = src.id;
    val.currency0 = src.currency0;
    val.currency1 = src.currency1;
    val.fee = src.fee;
    val.tickSpacing = src.tickSpacing;
    val.address = src.address;
    val.dex = src.dex;

    return val;
  }
}

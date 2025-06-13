import 'package:isar/isar.dart';
import 'package:tejory/singleton.dart';
part 'next_key.g.dart';

@Collection()
class NextKey {
  Id id = Isar.autoIncrement;
  int? wallet;
  int? coin;
  @Index(
      unique: true,
      composite: [CompositeIndex('coin'), CompositeIndex('wallet')])
  String? path;
  int? nextKey;

  Future<int> save() async {
    Isar isar = Singleton.getDB();

    int currentId = 0;

    await isar.writeTxn(() async {
      if (nextKey != null) {
        currentId = await isar.nextKeys.putByPathCoinWallet(this);
      }
    });
    return currentId;
  }
}

class NextKeyModel {
  const NextKeyModel();
  Future<NextKey?> getById(int id) async {
    Isar isar = Singleton.getDB();
    return isar.nextKeys.get(id);
  }

  Future<NextKey?> getUnique(int? wallet, int? coin, String? path) async {
    Isar isar = Singleton.getDB();
    return isar.nextKeys.getByPathCoinWallet(path, coin, wallet);
  }

  Future<List<NextKey>?> find({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
    int? limit,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<NextKey> query = isar.nextKeys.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc, limit: limit);
    try {
      return await query.findAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }

  Future<int?> count({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<NextKey> query = isar.nextKeys.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc);
    try {
      return await query.count();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }

  Future<int?> delete({
    FilterOperation? q,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<NextKey> query = isar.nextKeys.buildQuery(filter:q);
    try {
      return await query.deleteAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }
}

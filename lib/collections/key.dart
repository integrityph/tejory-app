import 'package:isar/isar.dart';
import 'package:tejory/singleton.dart';
part 'key.g.dart';

@Collection()
class Key {
  Id id = Isar.autoIncrement;
  int? wallet;
  int? coin;

  @Index(
      unique: true,
      composite: [CompositeIndex('wallet'), CompositeIndex('coin')])
  String? path;

  String? pubKey;
  String? chainCode;

  Future<int> save() async {
    Isar isar = Singleton.getDB();

    int currentId = 0;

    await isar.writeTxn(() async {
      if (pubKey != null) {
        currentId = await isar.keys.putByPathWalletCoin(this);
      }
    });
    return currentId;
  }
}

class KeyModel {
  const KeyModel();
  Future<Key?> getById(int id) async {
    Isar isar = Singleton.getDB();
    return isar.keys.get(id);
  }

  Future<Key?> getUnique(String? path, int? wallet, int? coin) async {
    Isar isar = Singleton.getDB();
    return isar.keys.getByPathWalletCoin(path, wallet, coin);
  }

  Future<List<Key>?> find({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
    int? limit,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<Key> query = isar.keys.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc, limit: limit);
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
    
    Query<Key> query = isar.keys.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc);
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
    
    Query<Key> query = isar.keys.buildQuery(filter:q);
    try {
      return await query.deleteAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }
}

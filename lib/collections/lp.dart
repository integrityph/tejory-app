import 'package:isar/isar.dart';
import 'package:tejory/singleton.dart';
part 'lp.g.dart';

@Collection()
class LP {
  Id id = Isar.autoIncrement;
  @Index(unique: true, composite: [CompositeIndex('currency1')])
  String? currency0;
  String? currency1;
  int? fee;
  int? tickSpacing;
  String? address;
  String? dex;

  Future<int> save() async {
    Isar isar = Singleton.getDB();

    int currentId = 0;

    await isar.writeTxn(() async {
      currentId = await isar.lPs.putByCurrency0Currency1(this);
    });
    return currentId;
  }
}

class LPModel {
  const LPModel();
  Future<LP?> getById(int id) async {
    Isar isar = Singleton.getDB();
    return isar.lPs.get(id);
  }

  Future<LP?> getUnique(String? currency0, String? currency1) async {
    Isar isar = Singleton.getDB();
    return isar.lPs.getByCurrency0Currency1(currency0, currency1);
  }

  Future<List<LP>?> find({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
    int? limit,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<LP> query = isar.lPs.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc, limit: limit);
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
    
    Query<LP> query = isar.lPs.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc);
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
    
    Query<LP> query = isar.lPs.buildQuery(filter:q);
    try {
      return await query.deleteAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }
}
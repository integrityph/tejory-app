import 'package:isar/isar.dart';
import 'package:tejory/singleton.dart';

part 'data_version.g.dart';

@Collection()
class DataVersion {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String? name;
  String? hash;
  int? counter;

  Future<int> save() async {
    Isar isar = Singleton.getDB();

    int currentId = 0;
    await isar.writeTxn(() async {
      currentId = await isar.dataVersions.putByName(this);
    });

    return currentId;
  }
}

class DataVersionModel {
  const DataVersionModel();
  Future<DataVersion?> getById(int id) async {
    Isar isar = Singleton.getDB();
    return isar.dataVersions.get(id);
  }

  Future<DataVersion?> getUnique(String? name) async {
    Isar isar = Singleton.getDB();
    return isar.dataVersions.getByName(name);
  }

  Future<List<DataVersion>?> find({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
    int? limit,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<DataVersion> query = isar.dataVersions.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc, limit: limit);
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
    
    Query<DataVersion> query = isar.dataVersions.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc);
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
    
    Query<DataVersion> query = isar.dataVersions.buildQuery(filter:q);
    try {
      return await query.deleteAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }
}
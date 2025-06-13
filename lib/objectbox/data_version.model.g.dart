// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_version.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension DataVersionBoxModelHelpers on DataVersion {
  Future<int?> save() async {
    return DataVersionModel().upsert(this);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class DataVersionModel extends BaseBoxModel<DataVersion, isar.DataVersion> {
  const DataVersionModel();

  Future<List<DataVersion>?> find({
    Condition<DataVersion>? q,
    QueryProperty<DataVersion, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.dataVersionBox.query(q);
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
      print("ERROR: DataVersion.find ${e}");
      return null;
    }
  }

  Future<int?> delete({
    Condition<DataVersion>? q,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.dataVersionBox.query(q);
    final query = queryBuilder.build();
    try {
      final result = query.remove();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: DataVersion.delete ${e}");
      return null;
    }
  }

  Future<int?> count({Condition<DataVersion>? q}) async {
    final objectbox = Singleton.getObjectBoxDB();
    final query = objectbox.dataVersionBox.query(q).build();
    try {
      return query.count();
    } catch (e) {
      print("ERROR: DataVersion.count ${e}");
      return null;
    } finally {
      query.close();
    }
  }

  Future<DataVersion?> getById(int id) async {
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.dataVersionBox.get(id);
  }

  Condition<DataVersion> uniqueCondition(String? name) {
    return ((name == null)
        ? DataVersion_.name.isNull()
        : DataVersion_.name.equals(name));
  }

  Future<DataVersion?> getUnique(String? name) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.dataVersionBox.query(uniqueCondition(name)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Future<int> upsert(DataVersion dataVersion) async {
    final box = Singleton.getObjectBoxDB();

    if (dataVersion.id != 0) {
      return box.dataVersionBox.put(dataVersion);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query =
          box.dataVersionBox.query(uniqueCondition(dataVersion.name)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        dataVersion.id = existingId[0];
      }

      return box.dataVersionBox.put(dataVersion);
    });
  }

  DataVersion fromIsar(isar.DataVersion src) {
    DataVersion val = DataVersion();
    val.id = src.id;
    val.name = src.name;
    val.hash = src.hash;
    val.counter = src.counter;

    return val;
  }
}

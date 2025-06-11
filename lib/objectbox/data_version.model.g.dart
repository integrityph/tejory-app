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

class DataVersionModel {
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
      final result = await query.findAsync();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: DataVersion.find ${e}");
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
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.dataVersionBox.getAsync(id);
  }

  Condition<DataVersion> uniqueCondition(String? name) {
    return ((name == null)
        ? DataVersion_.name.isNull()
        : DataVersion_.name.equals(name));
  }

  Future<DataVersion?> getUnique(String? name) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.dataVersionBox.query(uniqueCondition(name)).build();
    final result = await query.findFirstAsync();
    query.close();
    return result;
  }

  Future<int> upsert(DataVersion dataVersion) async {
    final box = Singleton.getObjectBoxDB();

    if (dataVersion.id != 0) {
      return box.dataVersionBox.putAsync(dataVersion);
    }

    return box.getStore().runInTransactionAsync(TxMode.write, (
      Store store,
      DataVersion dataVersion,
    ) {
      final query =
          box.dataVersionBox.query(uniqueCondition(dataVersion.name)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        dataVersion.id = existingId[0];
      }

      return store.box<DataVersion>().put(dataVersion);
    }, dataVersion);
  }
}

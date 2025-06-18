// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_version.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension DataVersionBoxModelHelpers on DataVersion {
  int? save() {
    return DataVersionModel().upsert(this);
  }

  String getCPK() {
    return DataVersionModel().calculateCPK(name);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class DataVersionModel extends BaseBoxModel<DataVersion, isar.DataVersion> {
  const DataVersionModel();

  List<DataVersion>? find({
    Condition<DataVersion>? q,
    QueryProperty<DataVersion, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) {
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

  int? delete({
    Condition<DataVersion>? q,
  }) {
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

  int? count({Condition<DataVersion>? q}) {
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

  DataVersion? getById(int id) {
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.dataVersionBox.get(id);
  }

  Condition<DataVersion> uniqueConditionMV(String? name) {
    return ((name == null)
        ? DataVersion_.name.isNull()
        : DataVersion_.name.equals(name));
  }

  Condition<DataVersion> uniqueCondition(String? name) {
    return DataVersion_.cpk.equals(calculateCPK(name));
  }

  String calculateCPK(String? name) {
    return CPK.calculateCPK([name]);
  }

  DataVersion? getUniqueMV(String? name) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.dataVersionBox.query(uniqueConditionMV(name)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  DataVersion? getUnique(String? name) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.dataVersionBox.query(uniqueCondition(name)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  int upsertMV(DataVersion dataVersion) {
    final box = Singleton.getObjectBoxDB();

    if (dataVersion.id != 0) {
      return box.dataVersionBox.put(dataVersion);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query =
          box.dataVersionBox.query(uniqueConditionMV(dataVersion.name)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        dataVersion.id = existingId[0];
      }

      return box.dataVersionBox.put(dataVersion);
    });
  }

  int upsert(DataVersion dataVersion) {
    final box = Singleton.getObjectBoxDB();
    dataVersion.cpk = dataVersion.getCPK();
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

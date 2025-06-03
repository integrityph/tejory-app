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
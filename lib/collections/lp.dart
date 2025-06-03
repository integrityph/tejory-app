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
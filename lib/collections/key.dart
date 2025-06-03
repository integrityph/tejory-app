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

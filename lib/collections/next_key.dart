import 'package:isar/isar.dart';
import 'package:tejory/singleton.dart';
part 'next_key.g.dart';

@Collection()
class NextKey {
  Id? id = Isar.autoIncrement;
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

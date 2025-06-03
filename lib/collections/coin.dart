import 'package:isar/isar.dart';
import 'package:tejory/singleton.dart';

part 'coin.g.dart';

@Collection()
class Coin {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String? name;
  int? hdCode;
  String? symbol;
  String? image;
  String? yahooFinance;
  int? decimals;
  String? hrpBech32;
  String? webId;
  String? peerSeedType;
  String? peerSource;
  int? defaultPort;
  String? magic;
  String? blockZeroHash;
  String? netVersionPublicHex;
  String? netVersionPrivateHex;
  String? contractHash;
  String? template;
  double? usdPrice;
  bool? active;

  Future<int> save() async {
    Isar isar = Singleton.getDB();

    int currentId = 0;
    await isar.writeTxn(() async {
      currentId = await isar.coins.putByName(this);
    });

    return currentId;
  }
}

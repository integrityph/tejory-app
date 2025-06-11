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
  bool? workerIsolateRequired;

  Future<int> save() async {
    Isar isar = Singleton.getDB();

    int currentId = 0;
    await isar.writeTxn(() async {
      currentId = await isar.coins.putByName(this);
    });

    return currentId;
  }
}

class CoinModel {
  const CoinModel();
  Future<Coin?> getById(int id) async {
    Isar isar = Singleton.getDB();
    return isar.coins.get(id);
  }

  Future<Coin?> getUnique(String? name) async {
    Isar isar = Singleton.getDB();
    return isar.coins.getByName(name);
  }

  Future<List<Coin>?> find({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
    int? limit,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<Coin> query = isar.coins.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc, limit: limit);
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
    
    Query<Coin> query = isar.coins.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc);
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
    
    Query<Coin> query = isar.coins.buildQuery(filter:q);
    try {
      return await query.deleteAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }
}

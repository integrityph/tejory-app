import 'package:isar/isar.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/wallets/wallet_type.dart';
part 'wallet_db.g.dart';

@Collection()
class WalletDB {
  Id id = Isar.autoIncrement;

  String? name;

  @Enumerated(EnumType.ordinal)
  WalletType type = WalletType.unknown;

  String? fingerPrint;

  String? extendedPrivKey;
  bool? easyImport;
  DateTime? startYear;
  String? serialNumber;

  Future<int> save() async {
    Isar isar = Singleton.getDB();

    int currentId = 0;

    await isar.writeTxn(() async {
      currentId = await isar.walletDBs.put(this);
    });
    return currentId;
  }
}

class WalletDBModel {
  const WalletDBModel();
  Future<WalletDB?> getById(int id) async {
    Isar isar = Singleton.getDB();
    return isar.walletDBs.get(id);
  }

  Future<WalletDB?> getUnique(int id) async {
    Isar isar = Singleton.getDB();
    return isar.walletDBs.get(id);
  }

  Future<List<WalletDB>?> find({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
    int? limit,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<WalletDB> query = isar.walletDBs.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc, limit: limit);
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
    
    Query<WalletDB> query = isar.walletDBs.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc);
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
    
    Query<WalletDB> query = isar.walletDBs.buildQuery(filter:q);
    try {
      return await query.deleteAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }
}

import 'package:isar/isar.dart';
import 'package:tejory/collections/block.dart';
import 'package:tejory/collections/tx.dart';
import 'package:tejory/singleton.dart';
part 'balance.g.dart';

@Collection()
class Balance {
  Id id = Isar.autoIncrement;
  @Index(unique: true, composite: [CompositeIndex('wallet')])
  int? coin;
  int? wallet;
  int? coinBalance;

  double? usdBalance;
  int? fiatBalanceDC;
  DateTime? lastUpdate;
  String? lastBlockUpdate;

  Future<int> save() async {
    Isar isar = Singleton.getDB();

    int currentId = 0;
    await isar.writeTxn(() async {
      currentId = await isar.balances.putByCoinWallet(this);
    });

    return currentId;
  }
}

class BalanceModel {
  const BalanceModel();
  Future<Balance?> getById(int id) async {
    Isar isar = Singleton.getDB();
    return isar.balances.get(id);
  }

  Future<Balance?> getUnique(int? coin, int? wallet) async {
    Isar isar = Singleton.getDB();
    return isar.balances.getByCoinWallet(coin, wallet);
  }

  Future<List<Balance>?> find({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
    int? limit,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<Balance> query = isar.balances.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc, limit: limit);
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
    
    Query<Balance> query = isar.balances.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc);
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
    
    Query<Balance> query = isar.balances.buildQuery(filter:q);
    try {
      return await query.deleteAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }
}

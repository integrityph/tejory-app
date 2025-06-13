import 'package:isar/isar.dart';
import 'package:tejory/collections/next_key.dart';
import 'package:tejory/crypto-helper/blockchain_api.dart';
import 'package:tejory/singleton.dart';
part 'tx.g.dart';

@Collection()
class TxDB {
  Id id = Isar.autoIncrement;
  int? wallet;
  int? coin;
  DateTime? time;
  int? amount;
  double? usdAmount;
  bool? isDeposit;

  @Index(
      unique: true,
      composite: [CompositeIndex('coin'), CompositeIndex('outputIndex')])
  String? hash;

  String? spendingTxHash;
  String? blockHash;
  int? fee;
  bool? spent;
  bool? confirmed;
  bool? verified;
  bool? failed;
  String? lockingScript;
  String? lockingScriptType;
  String? hdPath;
  int? outputIndex;

  Future<int> save() async {
    Isar isar = Singleton.getDB();

    int currentId = 0;

    if (usdAmount == null && time != null) {
      String coinSymbol = Singleton.assetList.assetListState.getAssetById(coin??0)?.yahooFinance??"";
      if (coinSymbol != "") {
        usdAmount = await getBlockchainAPIHistoricPrice(coinSymbol, time!);
      }
    }

    await isar.writeTxn(() async {
      if (hash != null) {
        currentId = await isar.txDBs.putByHashCoinOutputIndex(this);
      }
    });

    () async {
      if (hdPath != null) {
        List<String> pathParts = hdPath!.split("/");
        int index = int.parse(pathParts.last);
        String parentPath =
            pathParts.sublist(0, pathParts.length - 1).join("/");

        var nextKey = isar.nextKeys.getByPathCoinWalletSync(parentPath, coin, wallet);

        if (nextKey == null) {
          nextKey = NextKey();
          nextKey.coin = coin;
          nextKey.path = parentPath;
          nextKey.wallet = wallet;
          nextKey.nextKey = index + 1;
          nextKey.save();
        } else if (nextKey.nextKey! < (index + 1)) {
          nextKey.nextKey = index + 1;
          nextKey.save();
        }
      }
    }();

    return currentId;
  }
}

class TxDBModel {
  const TxDBModel();
  Future<TxDB?> getById(int id) async {
    Isar isar = Singleton.getDB();
    return isar.txDBs.get(id);
  }

  Future<TxDB?> getUnique(int? coin, String? hash, int? outputIndex) async {
    Isar isar = Singleton.getDB();
    return isar.txDBs.getByHashCoinOutputIndex(hash, coin, outputIndex);
  }

  Future<List<TxDB>?> find({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
    int? limit,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<TxDB> query = isar.txDBs.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc, limit: limit);
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
    
    Query<TxDB> query = isar.txDBs.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc);
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
    
    Query<TxDB> query = isar.txDBs.buildQuery(filter:q);
    try {
      return await query.deleteAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }
}

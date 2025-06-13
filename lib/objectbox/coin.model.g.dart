// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension CoinBoxModelHelpers on Coin {
  Future<int?> save() async {
    return CoinModel().upsert(this);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class CoinModel extends BaseBoxModel<Coin, isar.Coin> {
  const CoinModel();

  Future<List<Coin>?> find({
    Condition<Coin>? q,
    QueryProperty<Coin, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.coinBox.query(q);
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
      final result = await query.findAsync();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: Coin.find ${e}");
      return null;
    }
  }

  Future<int?> count({Condition<Coin>? q}) async {
    final objectbox = Singleton.getObjectBoxDB();
    final query = objectbox.coinBox.query(q).build();
    try {
      return query.count();
    } catch (e) {
      print("ERROR: Coin.count ${e}");
      return null;
    } finally {
      query.close();
    }
  }

  Future<Coin?> getById(int id) async {
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.coinBox.getAsync(id);
  }

  Condition<Coin> uniqueCondition(String? name) {
    return ((name == null) ? Coin_.name.isNull() : Coin_.name.equals(name));
  }

  Future<Coin?> getUnique(String? name) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.coinBox.query(uniqueCondition(name)).build();
    final result = await query.findFirstAsync();
    query.close();
    return result;
  }

  Future<int> upsert(Coin coin) async {
    final box = Singleton.getObjectBoxDB();

    if (coin.id != 0) {
      return box.coinBox.putAsync(coin);
    }

    return box.getStore().runInTransactionAsync(TxMode.write, (
      Store store,
      Coin coin,
    ) {
      final query = box.coinBox.query(uniqueCondition(coin.name)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        coin.id = existingId[0];
      }

      return store.box<Coin>().put(coin);
    }, coin);
  }

  Coin fromIsar(isar.Coin src) {
    Coin val = Coin();
    val.id = src.id;
    val.name = src.name;
    val.hdCode = src.hdCode;
    val.symbol = src.symbol;
    val.image = src.image;
    val.yahooFinance = src.yahooFinance;
    val.decimals = src.decimals;
    val.hrpBech32 = src.hrpBech32;
    val.webId = src.webId;
    val.peerSeedType = src.peerSeedType;
    val.peerSource = src.peerSource;
    val.defaultPort = src.defaultPort;
    val.magic = src.magic;
    val.blockZeroHash = src.blockZeroHash;
    val.netVersionPublicHex = src.netVersionPublicHex;
    val.netVersionPrivateHex = src.netVersionPrivateHex;
    val.contractHash = src.contractHash;
    val.template = src.template;
    val.usdPrice = src.usdPrice;
    val.active = src.active;
    val.workerIsolateRequired = src.workerIsolateRequired;

    return val;
  }
}

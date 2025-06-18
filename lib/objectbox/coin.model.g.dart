// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension CoinBoxModelHelpers on Coin {
  int? save() {
    return CoinModel().upsert(this);
  }

  String getCPK() {
    return CoinModel().calculateCPK(name);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class CoinModel extends BaseBoxModel<Coin, isar.Coin> {
  const CoinModel();

  List<Coin>? find({
    Condition<Coin>? q,
    QueryProperty<Coin, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) {
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
      final result = query.find();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: Coin.find ${e}");
      return null;
    }
  }

  int? delete({
    Condition<Coin>? q,
  }) {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.coinBox.query(q);
    final query = queryBuilder.build();
    try {
      final result = query.remove();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: Coin.delete ${e}");
      return null;
    }
  }

  int? count({Condition<Coin>? q}) {
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

  Coin? getById(int id) {
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.coinBox.get(id);
  }

  Condition<Coin> uniqueConditionMV(String? name) {
    return ((name == null) ? Coin_.name.isNull() : Coin_.name.equals(name));
  }

  Condition<Coin> uniqueCondition(String? name) {
    return Coin_.cpk.equals(calculateCPK(name));
  }

  String calculateCPK(String? name) {
    return CPK.calculateCPK([name]);
  }

  Coin? getUniqueMV(String? name) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.coinBox.query(uniqueConditionMV(name)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Coin? getUnique(String? name) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.coinBox.query(uniqueCondition(name)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  int upsertMV(Coin coin) {
    final box = Singleton.getObjectBoxDB();

    if (coin.id != 0) {
      return box.coinBox.put(coin);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query = box.coinBox.query(uniqueConditionMV(coin.name)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        coin.id = existingId[0];
      }

      return box.coinBox.put(coin);
    });
  }

  int upsert(Coin coin) {
    final box = Singleton.getObjectBoxDB();
    coin.cpk = coin.getCPK();
    if (coin.id != 0) {
      return box.coinBox.put(coin);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query = box.coinBox.query(uniqueCondition(coin.name)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        coin.id = existingId[0];
      }

      return box.coinBox.put(coin);
    });
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension BalanceBoxModelHelpers on Balance {
  Future<int?> save() async {
    return BalanceModel().upsert(this);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class BalanceModel extends BaseBoxModel<Balance, isar.Balance> {
  const BalanceModel();

  Future<List<Balance>?> find({
    Condition<Balance>? q,
    QueryProperty<Balance, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.balanceBox.query(q);
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
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }

  Future<int?> delete({
    Condition<Balance>? q,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.balanceBox.query(q);
    final query = queryBuilder.build();
    try {
      final result = query.remove();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: Balance.delete ${e}");
      return null;
    }
  }

  Future<int?> count({Condition<Balance>? q}) async {
    final objectbox = Singleton.getObjectBoxDB();
    final query = objectbox.balanceBox.query(q).build();
    try {
      return query.count();
    } catch (e) {
      print("ERROR: Balance.count ${e}");
      return null;
    } finally {
      query.close();
    }
  }

  Future<Balance?> getById(int id) async {
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.balanceBox.get(id);
  }

  Condition<Balance> uniqueCondition(int? coin, int? wallet) {
    return ((coin == null)
            ? Balance_.coin.isNull()
            : Balance_.coin.equals(coin)) &
        ((wallet == null)
            ? Balance_.wallet.isNull()
            : Balance_.wallet.equals(wallet));
  }

  Future<Balance?> getUnique(int? coin, int? wallet) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.balanceBox.query(uniqueCondition(coin, wallet)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Future<int> upsert(Balance balance) async {
    final box = Singleton.getObjectBoxDB();

    if (balance.id != 0) {
      return box.balanceBox.put(balance);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query = box.balanceBox
          .query(uniqueCondition(balance.coin, balance.wallet))
          .build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        balance.id = existingId[0];
      }

      return box.balanceBox.put(balance);
    });
  }

  Balance fromIsar(isar.Balance src) {
    Balance val = Balance();
    val.id = src.id;
    val.coin = src.coin;
    val.wallet = src.wallet;
    val.coinBalance = src.coinBalance;
    val.usdBalance = src.usdBalance;
    val.fiatBalanceDC = src.fiatBalanceDC;
    val.lastUpdate = src.lastUpdate;
    val.lastBlockUpdate = src.lastBlockUpdate;

    return val;
  }
}

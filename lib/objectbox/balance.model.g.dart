// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension BalanceBoxModelHelpers on Balance {
  int? save() {
    return BalanceModel().upsert(this);
  }

  String getCPK() {
    return BalanceModel().calculateCPK(coin, wallet);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class BalanceModel extends BaseBoxModel<Balance, isar.Balance> {
  const BalanceModel();

  List<Balance>? find({
    Condition<Balance>? q,
    QueryProperty<Balance, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) {
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

  int? delete({
    Condition<Balance>? q,
  }) {
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

  int? count({Condition<Balance>? q}) {
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

  Balance? getById(int id) {
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.balanceBox.get(id);
  }

  Condition<Balance> uniqueConditionMV(int? coin, int? wallet) {
    return ((coin == null)
            ? Balance_.coin.isNull()
            : Balance_.coin.equals(coin)) &
        ((wallet == null)
            ? Balance_.wallet.isNull()
            : Balance_.wallet.equals(wallet));
  }

  Condition<Balance> uniqueCondition(int? coin, int? wallet) {
    return Balance_.cpk.equals(calculateCPK(coin, wallet));
  }

  String calculateCPK(int? coin, int? wallet) {
    return CPK.calculateCPK([coin, wallet]);
  }

  Balance? getUniqueMV(int? coin, int? wallet) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.balanceBox.query(uniqueConditionMV(coin, wallet)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Balance? getUnique(int? coin, int? wallet) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.balanceBox.query(uniqueCondition(coin, wallet)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  int upsertMV(Balance balance) {
    final box = Singleton.getObjectBoxDB();

    if (balance.id != 0) {
      return box.balanceBox.put(balance);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query = box.balanceBox
          .query(uniqueConditionMV(balance.coin, balance.wallet))
          .build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        balance.id = existingId[0];
      }

      return box.balanceBox.put(balance);
    });
  }

  int upsert(Balance balance) {
    final box = Singleton.getObjectBoxDB();
    balance.cpk = balance.getCPK();
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

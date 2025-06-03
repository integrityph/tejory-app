import 'package:isar/isar.dart';
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

  Future<BigInt> getFromUTXORecords() async {
    BigInt balance = BigInt.zero;

    List<TxDB> utxoSet = Singleton.getDB()
        .txDBs
        .filter()
        .coinEqualTo(coin)
        .walletEqualTo(wallet)
        .findAllSync();

    for (int i = 0; i < utxoSet.length; i++) {
      if (utxoSet[i].spent! || !utxoSet[i].isDeposit!) {
        continue;
      }

      balance += BigInt.from(utxoSet[i].amount!);
    }

    return balance;
  }
}

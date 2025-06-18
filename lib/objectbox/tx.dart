import 'package:tejory/codegen/box_model/box_model.dart';
import 'package:tejory/codegen/box_model/ignore_in_isar_migration.dart';
import 'package:tejory/codegen/box_model/unique_index.dart';
import 'package:tejory/collections/tx.dart' as isar;
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
import 'package:tejory/objectbox/cpk.dart';
import 'package:tejory/objectbox/next_key.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';

part 'tx.model.g.dart';

@Entity()
@BoxModel()
class TxDB {
  @Id(assignable: true)
  int id = 0;
  @IgnoreInIsarMigration()
  @Index(type: IndexType.value)
  String? cpk;
  int? wallet;
  @Index()
  @UniqueIndex()
  int? coin;
  @Property(type: PropertyType.date)
  DateTime? time;
  int? amount;
  double? usdAmount;
  bool? isDeposit;
  @Index()
  @UniqueIndex()
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
  @Index()
  @UniqueIndex()
  int? outputIndex;

  String getCPK_() {
    return getCPK();
  }

  Future<int> save() async {
    // TODO: handle this in the isolate service
    // if (usdAmount == null && time != null) {
    //   String coinSymbol =
    //       Singleton.assetList.assetListState
    //           .getAssetById(coin ?? 0)
    //           ?.yahooFinance ??
    //       "";
    //   if (coinSymbol != "") {
    //     usdAmount = await getBlockchainAPIHistoricPrice(coinSymbol, time!);
    //   }
    // }

    if (hdPath != null) {
      () async {
        List<String> pathParts = hdPath!.split("/");
        int index = int.parse(pathParts.last);
        String parentPath = pathParts
            .sublist(0, pathParts.length - 1)
            .join("/");

        var nextKey = await NextKeyModel().getUnique(coin, wallet, parentPath);

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
      }();
    }

    return TxDBModel().upsert(this);
  }

  Future<void> bulkSaveTx(List<TxDB> txsToSave) async {
    final box = Singleton.getObjectBoxDB();

    await box.getStore().runInTransaction(TxMode.write, () {
      final model = TxDBModel();

      final List<TxDB> newTransactionsToProcess = [];
      final Set<String> hashesToLookup = {}; // To collect unique hashes for the query

      for (var tx in txsToSave) {
        if (tx.id == 0) { // This is a potentially new record
          newTransactionsToProcess.add(tx);
          if (tx.hash != null) {
            hashesToLookup.add(tx.hash!); // Collect hash for lookup
          }
        }
        // Records with tx.id != 0 are existing and will be updated by putMany
      }

      // If no new transactions or no hashes to lookup, simply put existing updates
      if (newTransactionsToProcess.isEmpty || hashesToLookup.isEmpty) {
        box.txDBBox.putMany(txsToSave);
        return;
      }

      // --- Strategy B: Query by most selective index (hash) + In-Memory Filtering ---

      // 1. Query all existing records that have one of the hashes we're interested in.
      //    This leverages the index on `TxDB_.hash`.
      final query = box.txDBBox.query(TxDB_.hash.oneOf(hashesToLookup.toList())).build();
      final List<TxDB> potentiallyExistingRecords = query.find();
      query.close();

      // 2. Create a lookup map from composite key object to existing TxDB object
      //    This map will be built from the potentiallyExistingRecords.
      final Map<TxCompositeKey, TxDB> existingUniqueKeyToRecordMap = {};
      for (var existingTx in potentiallyExistingRecords) {
        final TxCompositeKey compositeKey = TxCompositeKey(
            existingTx.coin, existingTx.hash, existingTx.outputIndex);
        existingUniqueKeyToRecordMap[compositeKey] = existingTx;
      }

      // 3. Assign existing IDs to the new transactions if a match is found
      for (var tx in newTransactionsToProcess) {
        final TxCompositeKey compositeKey = TxCompositeKey(tx.coin, tx.hash, tx.outputIndex);
        if (existingUniqueKeyToRecordMap.containsKey(compositeKey)) {
          tx.id = existingUniqueKeyToRecordMap[compositeKey]!.id; // Assign the existing ID
        }
        // If tx.id is still 0, it will be inserted as a new record by putMany.
      }

      // 4. Perform the bulk upsert (inserts new, updates existing by ID)
      box.txDBBox.putMany(txsToSave);
    });
  }
}

class TxCompositeKey {
  final int? coin;
  final String? hash;
  final int? outputIndex;

  TxCompositeKey(this.coin, this.hash, this.outputIndex);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TxCompositeKey &&
          runtimeType == other.runtimeType &&
          coin == other.coin &&
          hash == other.hash && // String comparison is efficient
          outputIndex == other.outputIndex);

  @override
  int get hashCode => Object.hash(coin, hash, outputIndex);
}
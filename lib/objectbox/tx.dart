import 'package:tejory/codegen/box_model/box_model.dart';
import 'package:tejory/codegen/box_model/unique_index.dart';
import 'package:tejory/collections/tx.dart' as isar;
import 'package:tejory/crypto-helper/blockchain_api.dart';
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
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

  Future<int> save() async {
    if (usdAmount == null && time != null) {
      String coinSymbol = Singleton.assetList.assetListState.getAssetById(coin??0)?.yahooFinance??"";
      if (coinSymbol != "") {
        usdAmount = await getBlockchainAPIHistoricPrice(coinSymbol, time!);
      }
    }

    () async {
      if (hdPath != null) {
        List<String> pathParts = hdPath!.split("/");
        int index = int.parse(pathParts.last);
        String parentPath =
            pathParts.sublist(0, pathParts.length - 1).join("/");

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
      }
    }();

    return TxDBModel().upsert(this);
  }
}

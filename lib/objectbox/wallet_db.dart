import 'package:tejory/codegen/box_model/box_model.dart';
import 'package:tejory/codegen/box_model/unique_index.dart';
import 'package:tejory/collections/wallet_db.dart' as isar;
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';
import 'package:tejory/wallets/wallet_type.dart';

part 'wallet_db.model.g.dart';

@Entity()
@BoxModel()
class WalletDB {
  @Id(assignable: true)
  int id = 0;
  String? name;
  @Transient()
  WalletType type = WalletType.unknown;
  int get dbType => type.index;
  set dbType(int value) {
    type = WalletType.values[value];
  }
  String? fingerPrint;
  String? extendedPrivKey;
  bool? easyImport;
  @Property(type: PropertyType.date)
  DateTime? startYear;
  @Index()
  String? serialNumber;
}
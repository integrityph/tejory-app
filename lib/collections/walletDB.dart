import 'package:isar/isar.dart';
part 'walletDB.g.dart';

enum WalletType { unknown, phone, tejoryCard }

@Collection()
class WalletDB {
  Id id = Isar.autoIncrement;

  String? name;

  @Enumerated(EnumType.ordinal)
  WalletType type = WalletType.unknown;

  String? fingerPrint;

  String? extendedPrivKey;
  bool? easyImport;
  DateTime? startYear;
  String? serialNumber;
}

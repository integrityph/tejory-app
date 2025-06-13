import 'package:tejory/codegen/box_model/box_model.dart';
import 'package:tejory/codegen/box_model/unique_index.dart';
import 'package:tejory/collections/coin.dart' as isar;
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';

part 'coin.model.g.dart';

@Entity()
@BoxModel()
class Coin {
  @Id(assignable: true)
  int id = 0;
  @Index()
  @UniqueIndex()
  String? name;
  int? hdCode;
  String? symbol;
  String? image;
  String? yahooFinance;
  int? decimals;
  String? hrpBech32;
  String? webId;
  String? peerSeedType;
  String? peerSource;
  int? defaultPort;
  String? magic;
  String? blockZeroHash;
  String? netVersionPublicHex;
  String? netVersionPrivateHex;
  String? contractHash;
  String? template;
  double? usdPrice;
  bool? active;
  bool? workerIsolateRequired;

}

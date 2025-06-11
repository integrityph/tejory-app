import 'package:tejory/codegen/box_model/box_model.dart';
import 'package:tejory/codegen/box_model/unique_index.dart';
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';

part 'balance.model.g.dart';

@Entity()
@BoxModel()
class Balance {
  @Id(assignable: true)
  int id = 0;
  @Index(type: IndexType.value)
  @UniqueIndex()
  int? coin;
  @Index(type: IndexType.value)
  @UniqueIndex()
  int? wallet;
  int? coinBalance;
  double? usdBalance;
  int? fiatBalanceDC;
  @Property(type: PropertyType.date)
  DateTime? lastUpdate;
  String? lastBlockUpdate;
}

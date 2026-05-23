import 'package:tejory/objectbox/box_model.dart';
import 'package:tejory/objectbox/ignore_in_isar_migration.dart';
import 'package:tejory/objectbox/unique_index.dart';
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
import 'package:tejory/objectbox/cpk.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';

part 'lp.model.g.dart';

@Entity()
@BoxModel()
class LP {
  @Id(assignable: true)
  int id = 0;
  @IgnoreInIsarMigration()
  @Index(type: IndexType.value)
  String? cpk;
  @Index()
  @UniqueIndex()
  String? currency0;
  @Index()
  @UniqueIndex()
  String? currency1;
  int? fee;
  int? tickSpacing;
  String? address;
  String? dex;

  String getCPK_() {
    return getCPK();
  }
}
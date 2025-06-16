import 'package:blockchain_utils/hex/hex.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:tejory/codegen/box_model/box_model.dart';
import 'package:tejory/codegen/box_model/ignore_in_isar_migration.dart';
import 'package:tejory/codegen/box_model/unique_index.dart';
import 'package:tejory/collections/next_key.dart' as isar;
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
import 'package:tejory/objectbox/cpk.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
import 'package:objectbox/objectbox.dart';

part 'next_key.model.g.dart';

@Entity()
@BoxModel()
class NextKey {
  @Id(assignable: true)
  int id = 0;
  @IgnoreInIsarMigration()
  @Index(type: IndexType.value)
  String? cpk;
  @Index()
  @UniqueIndex()
  int? wallet;
  @Index()
  @UniqueIndex()
  int? coin;
  @Index(type: IndexType.value)
  @UniqueIndex()
  String? path;
  int? nextKey;

  String getCPK_() {
    return getCPK();
  }
}

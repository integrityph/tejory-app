import 'package:cryptography/cryptography.dart';
import 'package:tejory/codegen/box_model/box_model.dart';
import 'package:tejory/codegen/box_model/ignore_in_isar_migration.dart';
import 'package:tejory/codegen/box_model/unique_index.dart';
import 'package:tejory/collections/block.dart' as isar;
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
import 'package:tejory/objectbox/cpk.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';

part 'block.model.g.dart';

@Entity()
@BoxModel()
class Block {
  @Id(assignable: true)
  int id = 0;
  @IgnoreInIsarMigration()
  @Index(type: IndexType.value)
  String? cpk;
  @Index(type: IndexType.value)
	@UniqueIndex()
  int? coin;
  @Index(type: IndexType.value)
	@UniqueIndex()
  String? hash;
  @Index(type: IndexType.value)
  int? height;
  @Property(type: PropertyType.date)
  DateTime? time;
  String? filePath;
  String? previousHash;

  String getCPK_() {
    return getCPK();
  }

  Future<int?> getHeight({int depth = 0}) async {
    if (height != null) {
      return height!;
    }
    if (depth > 25) {
      return null;
    }

    Block? previousBlock = await BlockModel().getUnique(coin, previousHash);

    if (previousBlock == null) {
      return null;
    }
    int? previousHeight = await previousBlock.getHeight(depth: depth + 1);
    if (previousHeight == null) {
      return null;
    }
    return previousHeight + 1;
  }

  Future<int?> calculateHeight({int depth = 0}) async {
    if (height != null) {
      return height!;
    }
    if (depth > 25) {
      return null;
    }
    var previousBlock = await BlockModel().getUnique(coin, previousHash);

    if (previousBlock == null) {
      return null;
    }
    int? previousHeight = await previousBlock.calculateHeight(depth: depth + 1);
    if (previousHeight == null) {
      return null;
    }
    await this.save();
    return previousHeight + 1;
  }
}

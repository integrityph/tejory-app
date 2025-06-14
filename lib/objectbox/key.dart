import 'package:tejory/codegen/box_model/box_model.dart';
import 'package:tejory/codegen/box_model/unique_index.dart';
import 'package:tejory/collections/key.dart' as isar;
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
import 'package:objectbox/objectbox.dart';

part 'key.model.g.dart';

@Entity()
@BoxModel()
class Key {
  @Id(assignable:true)
  int id = 0;
  @Index()
  @UniqueIndex()
  int? wallet;
  @Index()
  @UniqueIndex()
  int? coin;
  @Index()
  @UniqueIndex()
  String? path;
  String? pubKey;
  String? chainCode;
}

import 'package:tejory/codegen/box_model/box_model.dart';
import 'package:tejory/codegen/box_model/unique_index.dart';
import 'package:tejory/collections/data_version.dart' as isar;
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/base_box_model.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';

part 'data_version.model.g.dart';

@Entity()
@BoxModel()
class DataVersion {
  @Id(assignable: true)
  int id = 0;
  @Index()
  @UniqueIndex()
  String? name;
  String? hash;
  int? counter;
}
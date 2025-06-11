import 'package:tejory/codegen/box_model/box_model.dart';
import 'package:tejory/codegen/box_model/unique_index.dart';
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
import 'package:objectbox/objectbox.dart';

part 'lp.model.g.dart';

@Entity()
@BoxModel()
class LP {
  @Id(assignable: true)
  int id = 0;
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
}
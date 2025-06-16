import 'package:objectbox/objectbox.dart';
import 'package:tejory/objectbox.g.dart';

abstract class BaseBoxModel<T ,IsarT> {
  const BaseBoxModel();

  List<T>? find({
    Condition<T>? q,
    QueryProperty<T, dynamic>? order,
    bool ascending = true,
    int? limit,
  });
  int? count({Condition<T>? q});
  T? getById(int id);
  T fromIsar(IsarT val);
}
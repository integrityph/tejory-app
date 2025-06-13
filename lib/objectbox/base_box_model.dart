import 'package:objectbox/objectbox.dart';
import 'package:tejory/objectbox.g.dart';

abstract class BaseBoxModel<T ,IsarT> {
  const BaseBoxModel();

  Future<List<T>?> find({
    Condition<T>? q,
    QueryProperty<T, dynamic>? order,
    bool ascending = true,
    int? limit,
  });
  Future<int?> count({Condition<T>? q});
  Future<T?> getById(int id);
  T fromIsar(IsarT val);
}
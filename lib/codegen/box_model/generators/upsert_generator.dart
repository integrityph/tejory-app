import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../box_model.dart';
import 'helpers/get_unique_index_fields.dart';

class UpsertGenerator extends GeneratorForAnnotation<BoxModel> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@BoxModel` can only be used on classes.',
      );
    }

    final uniqueKeyFields = getUniqueIndexFields(element);
    final className = element.name;
    final classVariableName =
        '${className[0].toLowerCase()}${className.substring(1)}';
    final boxName = '${className[0].toLowerCase()}${className.substring(1)}Box';
    final fieldNames = uniqueKeyFields
        .map((f) {
          return '$classVariableName.${f.name}';
        })
        .join(", ");

    return '''
      Future<int> upsert($className $classVariableName) async {
        final box = Singleton.getObjectBoxDB();

        if ($classVariableName.id != 0) {
          return box.$boxName.putAsync($classVariableName);
        }

        return box.getStore().runInTransactionAsync(TxMode.write, (
          Store store,
          $className $classVariableName,
        ) {
          final query = box.$boxName.query(uniqueCondition($fieldNames)).build();
          final existingId = query.findIds();
          query.close();

          if (existingId.isNotEmpty) {
            $classVariableName.id = existingId[0];
          }

          return store.box<$className>().put($classVariableName);
        }, $classVariableName);
      }
    ''';
  }
}

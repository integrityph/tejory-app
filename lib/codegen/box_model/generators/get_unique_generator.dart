import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../box_model.dart';
import 'helpers/get_unique_index_fields.dart';

class GetUniqueGenerator extends GeneratorForAnnotation<BoxModel> {
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

    final parameters = uniqueKeyFields
        .map((f) {
          return '${f.type} ${f.name}';
        })
        .join(', ');

    final className = element.name;
    final boxName = '${className[0].toLowerCase()}${className.substring(1)}Box';
    final fieldNames = uniqueKeyFields
        .map((f) {
          return f.name;
        })
        .join(", ");

    return '''
      $className? getUniqueMV($parameters) {
        ObjectBox box = Singleton.getObjectBoxDB();
        final query = box.$boxName.query(uniqueConditionMV($fieldNames)).build();
        final result = query.findFirst();
        query.close();
        return result;
      }
    ''';
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../box_model.dart';
import 'helpers/get_unique_index_fields.dart';

class UniqueConditionCPKGenerator extends GeneratorForAnnotation<BoxModel> {
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
    final callParameters = uniqueKeyFields
        .map((f) {
          return '${f.name}';
        })
        .join(', ');
    final className = element.name;

    return '''
      Condition<$className> uniqueCondition($parameters) {
        return ${className}_.cpk.equals(calculateCPK($callParameters));
      }
    ''';
  }
}

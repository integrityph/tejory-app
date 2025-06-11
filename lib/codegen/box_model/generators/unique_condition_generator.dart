import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import '../box_model.dart';
import 'helpers/get_unique_index_fields.dart';

class UniqueConditionGenerator extends GeneratorForAnnotation<BoxModel> {
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

    final conditions = uniqueKeyFields
        .map((f) {
          final fieldName = f.name;
          if (f.type.nullabilitySuffix != NullabilitySuffix.question) {
            return '${className}_.${fieldName}.equals(${fieldName})';
          }
          return '((${fieldName} == null) ? ${className}_.${fieldName}.isNull() : ${className}_.${fieldName}.equals(${fieldName}))';
        })
        .join(' & \n');

    return '''
      Condition<$className> uniqueCondition($parameters) {
        return $conditions;
      }
    ''';
  }
}

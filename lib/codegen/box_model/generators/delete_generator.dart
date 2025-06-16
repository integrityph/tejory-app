import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../box_model.dart';

class DeleteGenerator extends GeneratorForAnnotation<BoxModel> {

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@BoxModel` can only be used on classes.',
        element: element,
      );
    }

    final className = element.name;

    final boxName = '${className[0].toLowerCase()}${className.substring(1)}Box';

    final generatedCode = '''
      int? delete({
          Condition<$className>? q,
      }) {
        final objectbox = Singleton.getObjectBoxDB();
        var queryBuilder = objectbox.$boxName.query(q);
        final query = queryBuilder.build();
        try {
          final result = query.remove();
          query.close();
          return result;
        } catch (e) {
          print("ERROR: $className.delete \${e}");
          return null;
        }
      }
  ''';

    return generatedCode;
  }
}
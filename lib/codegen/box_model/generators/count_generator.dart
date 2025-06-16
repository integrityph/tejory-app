import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../box_model.dart';

class CountGenerator extends GeneratorForAnnotation<BoxModel> {

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
      int? count({Condition<$className>? q}) {
        final objectbox = Singleton.getObjectBoxDB();
        final query = objectbox.$boxName.query(q).build();
        try {
          return query.count();
        } catch (e) {
          print("ERROR: $className.count \${e}");
          return null;
        } finally {
          query.close();
        }
      }
  ''';

    return generatedCode;
  }
}

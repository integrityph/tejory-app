import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../box_model.dart'; // Import your annotation class

class GetByIdGenerator extends GeneratorForAnnotation<BoxModel> {
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
      Future<$className?> getById(int id) async {
        final objectbox = Singleton.getObjectBoxDB();
        return objectbox.$boxName.getAsync(id);
      }
  ''';

    return generatedCode;
  }
}

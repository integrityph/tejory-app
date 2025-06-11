import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../box_model.dart';

class StaticModelGenerator extends GeneratorForAnnotation<BoxModel> {
  final List<GeneratorForAnnotation<BoxModel>> generators;

  StaticModelGenerator(this.generators);

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
    final generatedCode = '''
    class ${className}Model {
      const ${className}Model();

      ${generators.map((gen)=>gen.generateForAnnotatedElement(element, annotation, buildStep)).join("\n")}
    }
  ''';

    return generatedCode;
  }
}

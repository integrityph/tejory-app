import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../box_model.dart';

class ExtentionGenerator extends GeneratorForAnnotation<BoxModel> {
  final List<GeneratorForAnnotation<BoxModel>> generators;

  ExtentionGenerator(this.generators);

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
    extension ${className}BoxModelHelpers on $className {
      ${generators.map((gen)=>gen.generateForAnnotatedElement(element, annotation, buildStep)).join("\n")}
    }
  ''';

    return generatedCode;
  }
}

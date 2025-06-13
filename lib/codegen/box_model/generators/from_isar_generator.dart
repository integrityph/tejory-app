import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../box_model.dart';

class FromIsarGenerator extends GeneratorForAnnotation<BoxModel> {

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

    String fields = element.fields.where((field)=>!field.isSynthetic).map((field){
      return '    val.${field.name} = src.${field.name};';
    }).toList().join("\n");


    final generatedCode = '''
      $className fromIsar(isar.$className src) {
         $className val = $className();
         ${fields}

         return val;
      }
  ''';

    return generatedCode;
  }
}
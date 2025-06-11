import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../box_model.dart';

class ModelCollectorGenerator extends GeneratorForAnnotation<BoxModel> {
  ModelCollectorGenerator();

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return super.generate(library, buildStep);
  }

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@BoxModel` can only be used on classes.',
        element: element,
      );
    }

    final className = element.name;

    // add this model to the list of models
    final metadata = {
      'className': className,
      'importPath': buildStep.inputId.path, // e.g., "lib/objectbox/balance.dart"
      'helperClassName': '${className}Model',
    };
    // Create an AssetId for the hidden metadata file
    final metaAssetId = buildStep.inputId.changeExtension('.model.meta.json');
    await buildStep.writeAsString(metaAssetId, jsonEncode(metadata));

    return "";
  }
}

import 'dart:convert';
import 'package:build/build.dart';
import 'package:glob/glob.dart';

class ModelAggregatorGenerator implements Builder {
  // Tell build_runner that this builder creates one specific file.
  @override
  final buildExtensions = const {
    r'$lib$': ['box_models.g.dart'] // The input is the whole lib, the output is one file.
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();

    final modelInfos = <Map<String, dynamic>>[];

    // 1. Find all the hidden metadata files generated in Phase 1.
    await for (final input in buildStep.findAssets(Glob('**/*.model.meta.json'))) {
      final content = await buildStep.readAsString(input);
      modelInfos.add(jsonDecode(content) as Map<String, dynamic>);
    }
    
    // Sort them for consistent output
    modelInfos.sort((a, b) => a['className'].compareTo(b['className']));

    // 2. Generate the necessary imports for each model's helper file.
    for (final info in modelInfos) {
      // The path needs to be relative, this might need tweaking
      final importPath = info['importPath'].replaceFirst('lib/', 'package:tejory/');
      buffer.writeln("import '$importPath';");
    }
    buffer.writeln();

    // 3. Generate the Models facade class.
    buffer.writeln('class Models {');
    buffer.writeln('  Models._();\n');

    for (final info in modelInfos) {
      final typeName = info['className'];
      final fieldName = '${typeName[0].toLowerCase()}${typeName.substring(1)}';
      final modelHelperName = info['helperClassName'];
      buffer.writeln('  static const $fieldName = $modelHelperName();');
    }

    buffer.writeln('}');

    // 4. Write the final, single output file.
    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/box_models.g.dart'),
      buffer.toString(),
    );
  }
}
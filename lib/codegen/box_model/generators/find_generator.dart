import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../box_model.dart';

class FindGenerator extends GeneratorForAnnotation<BoxModel> {

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
      List<$className>? find({
          Condition<$className>? q,
          QueryProperty<$className, dynamic>? order,
          bool ascending = true,
          int? limit,
      }) {
        final objectbox = Singleton.getObjectBoxDB();
        var queryBuilder = objectbox.$boxName.query(q);
        if (order != null) {
          queryBuilder = queryBuilder.order(
            order,
            flags: ascending ? 0 : Order.descending,
          );
        }
        final query = queryBuilder.build();
        if (limit != null) {
          query.limit = limit;
        }
        try {
          final result = query.find();
          query.close();
          return result;
        } catch (e) {
          print("ERROR: $className.find \${e}");
          return null;
        }
      }
  ''';

    return generatedCode;
  }
}
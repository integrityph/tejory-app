import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:objectbox/objectbox.dart';
import '../../unique_index.dart';

List<FieldElement> getUniqueIndexFields(ClassElement element) {
// This is the list that will hold all fields marked with @UniqueIndex
    final uniqueKeyFields = <FieldElement>[];
    
    // 2. CREATE A TYPECHECKER for your field-level annotation.
    //    This is how we reliably identify the annotation.
    final uniqueIndexChecker = TypeChecker.fromRuntime(UniqueIndex);
    final idChecker = TypeChecker.fromRuntime(Id);

    // 3. LOOP through all the fields in the annotated class.
    FieldElement? idField;
    for (final field in element.fields) {
      // 4. CHECK if the current field has the @UniqueIndex annotation.
      if (uniqueIndexChecker.hasAnnotationOf(field)) {
        // If it does, add it to our list.
        uniqueKeyFields.add(field);
      }
      if (idChecker.hasAnnotationOf(field)) {
        idField = field;
      }
    }

    // If no fields were marked, there's nothing to generate.
    if (uniqueKeyFields.isEmpty) {
      uniqueKeyFields.add(idField!);
    }

    return uniqueKeyFields;
}
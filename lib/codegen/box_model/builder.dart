import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tejory/codegen/box_model/generators/count_generator.dart';
import 'package:tejory/codegen/box_model/generators/delete_generator.dart';
import 'package:tejory/codegen/box_model/generators/find_generator.dart';
import 'package:tejory/codegen/box_model/generators/from_isar_generator.dart';
import 'package:tejory/codegen/box_model/generators/get_by_id_generator.dart';
import 'package:tejory/codegen/box_model/generators/get_cpk_generator.dart';
import 'package:tejory/codegen/box_model/generators/calculate_cpk_generator.dart';
import 'package:tejory/codegen/box_model/generators/get_unique_generator.dart';
import 'package:tejory/codegen/box_model/generators/extention_generator.dart';
import 'package:tejory/codegen/box_model/generators/get_unique_generator_cpk.dart';
import 'package:tejory/codegen/box_model/generators/model_aggregator_generator.dart';
import 'package:tejory/codegen/box_model/generators/model_collector_generator.dart';
import 'package:tejory/codegen/box_model/generators/save_generator.dart';
import 'package:tejory/codegen/box_model/generators/static_model_generator.dart';
import 'package:tejory/codegen/box_model/generators/unique_condition_cpk_generator.dart';
import 'package:tejory/codegen/box_model/generators/unique_condition_generator.dart';
import 'package:tejory/codegen/box_model/generators/upsert_cpk_generator.dart';
import 'package:tejory/codegen/box_model/generators/upsert_generator.dart';

Builder boxModelBuilder(BuilderOptions options) {
  return PartBuilder([
    ExtentionGenerator([
      SaveGenerator(),
      GetCPKGenerator(),
    ]),
    StaticModelGenerator([
      FindGenerator(),
      DeleteGenerator(),
      CountGenerator(),
      GetByIdGenerator(),
      UniqueConditionGenerator(),
      UniqueConditionCPKGenerator(),
      CalculateCPKGenerator(),
      GetUniqueGenerator(),
      GetUniqueGeneratorCPK(),
      UpsertGenerator(),
      UpsertCPKGenerator(),
      FromIsarGenerator(),
    ])
  ], '.model.g.dart');
}

Builder boxCollectorBuilder(BuilderOptions options) {
  return PartBuilder([ModelCollectorGenerator()], '.model.meta.json');
}

Builder boxAggregatorBuilder(BuilderOptions options) {
  return ModelAggregatorGenerator();
}

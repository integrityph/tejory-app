import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'generators/count_generator.dart';
import 'generators/delete_generator.dart';
import 'generators/find_generator.dart';
import 'generators/get_by_id_generator.dart';
import 'generators/get_cpk_generator.dart';
import 'generators/calculate_cpk_generator.dart';
import 'generators/get_unique_generator.dart';
import 'generators/extention_generator.dart';
import 'generators/get_unique_generator_cpk.dart';
import 'generators/model_aggregator_generator.dart';
import 'generators/model_collector_generator.dart';
import 'generators/save_generator.dart';
import 'generators/static_model_generator.dart';
import 'generators/unique_condition_cpk_generator.dart';
import 'generators/unique_condition_generator.dart';
import 'generators/upsert_cpk_generator.dart';
import 'generators/upsert_generator.dart';

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
      // FromIsarGenerator(),
    ])
  ], '.model.g.dart');
}

Builder boxCollectorBuilder(BuilderOptions options) {
  return PartBuilder([ModelCollectorGenerator()], '.model.meta.json');
}

Builder boxAggregatorBuilder(BuilderOptions options) {
  return ModelAggregatorGenerator();
}

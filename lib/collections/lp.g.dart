// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lp.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLPCollection on Isar {
  IsarCollection<LP> get lPs => this.collection();
}

const LPSchema = CollectionSchema(
  name: r'LP',
  id: 1765822439389718905,
  properties: {
    r'address': PropertySchema(
      id: 0,
      name: r'address',
      type: IsarType.string,
    ),
    r'currency0': PropertySchema(
      id: 1,
      name: r'currency0',
      type: IsarType.string,
    ),
    r'currency1': PropertySchema(
      id: 2,
      name: r'currency1',
      type: IsarType.string,
    ),
    r'dex': PropertySchema(
      id: 3,
      name: r'dex',
      type: IsarType.string,
    ),
    r'fee': PropertySchema(
      id: 4,
      name: r'fee',
      type: IsarType.long,
    ),
    r'tickSpacing': PropertySchema(
      id: 5,
      name: r'tickSpacing',
      type: IsarType.long,
    )
  },
  estimateSize: _lPEstimateSize,
  serialize: _lPSerialize,
  deserialize: _lPDeserialize,
  deserializeProp: _lPDeserializeProp,
  idName: r'id',
  indexes: {
    r'currency0_currency1': IndexSchema(
      id: 5902141703454783139,
      name: r'currency0_currency1',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'currency0',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'currency1',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _lPGetId,
  getLinks: _lPGetLinks,
  attach: _lPAttach,
  version: '3.1.0+1',
);

int _lPEstimateSize(
  LP object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.address;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currency0;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currency1;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _lPSerialize(
  LP object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.address);
  writer.writeString(offsets[1], object.currency0);
  writer.writeString(offsets[2], object.currency1);
  writer.writeString(offsets[3], object.dex);
  writer.writeLong(offsets[4], object.fee);
  writer.writeLong(offsets[5], object.tickSpacing);
}

LP _lPDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LP();
  object.address = reader.readStringOrNull(offsets[0]);
  object.currency0 = reader.readStringOrNull(offsets[1]);
  object.currency1 = reader.readStringOrNull(offsets[2]);
  object.dex = reader.readStringOrNull(offsets[3]);
  object.fee = reader.readLongOrNull(offsets[4]);
  object.id = id;
  object.tickSpacing = reader.readLongOrNull(offsets[5]);
  return object;
}

P _lPDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _lPGetId(LP object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _lPGetLinks(LP object) {
  return [];
}

void _lPAttach(IsarCollection<dynamic> col, Id id, LP object) {
  object.id = id;
}

extension LPByIndex on IsarCollection<LP> {
  Future<LP?> getByCurrency0Currency1(String? currency0, String? currency1) {
    return getByIndex(r'currency0_currency1', [currency0, currency1]);
  }

  LP? getByCurrency0Currency1Sync(String? currency0, String? currency1) {
    return getByIndexSync(r'currency0_currency1', [currency0, currency1]);
  }

  Future<bool> deleteByCurrency0Currency1(
      String? currency0, String? currency1) {
    return deleteByIndex(r'currency0_currency1', [currency0, currency1]);
  }

  bool deleteByCurrency0Currency1Sync(String? currency0, String? currency1) {
    return deleteByIndexSync(r'currency0_currency1', [currency0, currency1]);
  }

  Future<List<LP?>> getAllByCurrency0Currency1(
      List<String?> currency0Values, List<String?> currency1Values) {
    final len = currency0Values.length;
    assert(currency1Values.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([currency0Values[i], currency1Values[i]]);
    }

    return getAllByIndex(r'currency0_currency1', values);
  }

  List<LP?> getAllByCurrency0Currency1Sync(
      List<String?> currency0Values, List<String?> currency1Values) {
    final len = currency0Values.length;
    assert(currency1Values.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([currency0Values[i], currency1Values[i]]);
    }

    return getAllByIndexSync(r'currency0_currency1', values);
  }

  Future<int> deleteAllByCurrency0Currency1(
      List<String?> currency0Values, List<String?> currency1Values) {
    final len = currency0Values.length;
    assert(currency1Values.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([currency0Values[i], currency1Values[i]]);
    }

    return deleteAllByIndex(r'currency0_currency1', values);
  }

  int deleteAllByCurrency0Currency1Sync(
      List<String?> currency0Values, List<String?> currency1Values) {
    final len = currency0Values.length;
    assert(currency1Values.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([currency0Values[i], currency1Values[i]]);
    }

    return deleteAllByIndexSync(r'currency0_currency1', values);
  }

  Future<Id> putByCurrency0Currency1(LP object) {
    return putByIndex(r'currency0_currency1', object);
  }

  Id putByCurrency0Currency1Sync(LP object, {bool saveLinks = true}) {
    return putByIndexSync(r'currency0_currency1', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCurrency0Currency1(List<LP> objects) {
    return putAllByIndex(r'currency0_currency1', objects);
  }

  List<Id> putAllByCurrency0Currency1Sync(List<LP> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'currency0_currency1', objects,
        saveLinks: saveLinks);
  }
}

extension LPQueryWhereSort on QueryBuilder<LP, LP, QWhere> {
  QueryBuilder<LP, LP, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LPQueryWhere on QueryBuilder<LP, LP, QWhereClause> {
  QueryBuilder<LP, LP, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> currency0IsNullAnyCurrency1() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'currency0_currency1',
        value: [null],
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> currency0IsNotNullAnyCurrency1() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'currency0_currency1',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> currency0EqualToAnyCurrency1(
      String? currency0) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'currency0_currency1',
        value: [currency0],
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> currency0NotEqualToAnyCurrency1(
      String? currency0) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'currency0_currency1',
              lower: [],
              upper: [currency0],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'currency0_currency1',
              lower: [currency0],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'currency0_currency1',
              lower: [currency0],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'currency0_currency1',
              lower: [],
              upper: [currency0],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> currency0EqualToCurrency1IsNull(
      String? currency0) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'currency0_currency1',
        value: [currency0, null],
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> currency0EqualToCurrency1IsNotNull(
      String? currency0) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'currency0_currency1',
        lower: [currency0, null],
        includeLower: false,
        upper: [
          currency0,
        ],
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> currency0Currency1EqualTo(
      String? currency0, String? currency1) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'currency0_currency1',
        value: [currency0, currency1],
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterWhereClause> currency0EqualToCurrency1NotEqualTo(
      String? currency0, String? currency1) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'currency0_currency1',
              lower: [currency0],
              upper: [currency0, currency1],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'currency0_currency1',
              lower: [currency0, currency1],
              includeLower: false,
              upper: [currency0],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'currency0_currency1',
              lower: [currency0, currency1],
              includeLower: false,
              upper: [currency0],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'currency0_currency1',
              lower: [currency0],
              upper: [currency0, currency1],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LPQueryFilter on QueryBuilder<LP, LP, QFilterCondition> {
  QueryBuilder<LP, LP, QAfterFilterCondition> addressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'address',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'address',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'address',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'address',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> addressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currency0',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currency0',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency0',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currency0',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currency0',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currency0',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currency0',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currency0',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0Contains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency0',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0Matches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency0',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency0',
        value: '',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency0IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency0',
        value: '',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currency1',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currency1',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currency1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currency1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currency1',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currency1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currency1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1Contains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1Matches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency1',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency1',
        value: '',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> currency1IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency1',
        value: '',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dex',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dex',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dex',
        value: '',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> dexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dex',
        value: '',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> feeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fee',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> feeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fee',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> feeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fee',
        value: value,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> feeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fee',
        value: value,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> feeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fee',
        value: value,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> feeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fee',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> tickSpacingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tickSpacing',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> tickSpacingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tickSpacing',
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> tickSpacingEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tickSpacing',
        value: value,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> tickSpacingGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tickSpacing',
        value: value,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> tickSpacingLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tickSpacing',
        value: value,
      ));
    });
  }

  QueryBuilder<LP, LP, QAfterFilterCondition> tickSpacingBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tickSpacing',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LPQueryObject on QueryBuilder<LP, LP, QFilterCondition> {}

extension LPQueryLinks on QueryBuilder<LP, LP, QFilterCondition> {}

extension LPQuerySortBy on QueryBuilder<LP, LP, QSortBy> {
  QueryBuilder<LP, LP, QAfterSortBy> sortByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByCurrency0() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency0', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByCurrency0Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency0', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByCurrency1() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency1', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByCurrency1Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency1', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByDex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dex', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByDexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dex', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByTickSpacing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickSpacing', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> sortByTickSpacingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickSpacing', Sort.desc);
    });
  }
}

extension LPQuerySortThenBy on QueryBuilder<LP, LP, QSortThenBy> {
  QueryBuilder<LP, LP, QAfterSortBy> thenByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByCurrency0() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency0', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByCurrency0Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency0', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByCurrency1() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency1', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByCurrency1Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency1', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByDex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dex', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByDexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dex', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByTickSpacing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickSpacing', Sort.asc);
    });
  }

  QueryBuilder<LP, LP, QAfterSortBy> thenByTickSpacingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickSpacing', Sort.desc);
    });
  }
}

extension LPQueryWhereDistinct on QueryBuilder<LP, LP, QDistinct> {
  QueryBuilder<LP, LP, QDistinct> distinctByAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'address', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LP, LP, QDistinct> distinctByCurrency0(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency0', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LP, LP, QDistinct> distinctByCurrency1(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency1', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LP, LP, QDistinct> distinctByDex({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dex', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LP, LP, QDistinct> distinctByFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fee');
    });
  }

  QueryBuilder<LP, LP, QDistinct> distinctByTickSpacing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tickSpacing');
    });
  }
}

extension LPQueryProperty on QueryBuilder<LP, LP, QQueryProperty> {
  QueryBuilder<LP, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LP, String?, QQueryOperations> addressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'address');
    });
  }

  QueryBuilder<LP, String?, QQueryOperations> currency0Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency0');
    });
  }

  QueryBuilder<LP, String?, QQueryOperations> currency1Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency1');
    });
  }

  QueryBuilder<LP, String?, QQueryOperations> dexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dex');
    });
  }

  QueryBuilder<LP, int?, QQueryOperations> feeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fee');
    });
  }

  QueryBuilder<LP, int?, QQueryOperations> tickSpacingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tickSpacing');
    });
  }
}

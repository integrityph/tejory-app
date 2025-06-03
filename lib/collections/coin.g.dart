// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCoinCollection on Isar {
  IsarCollection<Coin> get coins => this.collection();
}

const CoinSchema = CollectionSchema(
  name: r'Coin',
  id: -4922709809844936540,
  properties: {
    r'active': PropertySchema(
      id: 0,
      name: r'active',
      type: IsarType.bool,
    ),
    r'blockZeroHash': PropertySchema(
      id: 1,
      name: r'blockZeroHash',
      type: IsarType.string,
    ),
    r'contractHash': PropertySchema(
      id: 2,
      name: r'contractHash',
      type: IsarType.string,
    ),
    r'decimals': PropertySchema(
      id: 3,
      name: r'decimals',
      type: IsarType.long,
    ),
    r'defaultPort': PropertySchema(
      id: 4,
      name: r'defaultPort',
      type: IsarType.long,
    ),
    r'hdCode': PropertySchema(
      id: 5,
      name: r'hdCode',
      type: IsarType.long,
    ),
    r'hrpBech32': PropertySchema(
      id: 6,
      name: r'hrpBech32',
      type: IsarType.string,
    ),
    r'image': PropertySchema(
      id: 7,
      name: r'image',
      type: IsarType.string,
    ),
    r'magic': PropertySchema(
      id: 8,
      name: r'magic',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 9,
      name: r'name',
      type: IsarType.string,
    ),
    r'netVersionPrivateHex': PropertySchema(
      id: 10,
      name: r'netVersionPrivateHex',
      type: IsarType.string,
    ),
    r'netVersionPublicHex': PropertySchema(
      id: 11,
      name: r'netVersionPublicHex',
      type: IsarType.string,
    ),
    r'peerSeedType': PropertySchema(
      id: 12,
      name: r'peerSeedType',
      type: IsarType.string,
    ),
    r'peerSource': PropertySchema(
      id: 13,
      name: r'peerSource',
      type: IsarType.string,
    ),
    r'symbol': PropertySchema(
      id: 14,
      name: r'symbol',
      type: IsarType.string,
    ),
    r'template': PropertySchema(
      id: 15,
      name: r'template',
      type: IsarType.string,
    ),
    r'usdPrice': PropertySchema(
      id: 16,
      name: r'usdPrice',
      type: IsarType.double,
    ),
    r'webId': PropertySchema(
      id: 17,
      name: r'webId',
      type: IsarType.string,
    ),
    r'yahooFinance': PropertySchema(
      id: 18,
      name: r'yahooFinance',
      type: IsarType.string,
    )
  },
  estimateSize: _coinEstimateSize,
  serialize: _coinSerialize,
  deserialize: _coinDeserialize,
  deserializeProp: _coinDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _coinGetId,
  getLinks: _coinGetLinks,
  attach: _coinAttach,
  version: '3.1.0+1',
);

int _coinEstimateSize(
  Coin object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.blockZeroHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contractHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.hrpBech32;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.image;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.magic;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.netVersionPrivateHex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.netVersionPublicHex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.peerSeedType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.peerSource;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.symbol;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.template;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.webId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.yahooFinance;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _coinSerialize(
  Coin object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.active);
  writer.writeString(offsets[1], object.blockZeroHash);
  writer.writeString(offsets[2], object.contractHash);
  writer.writeLong(offsets[3], object.decimals);
  writer.writeLong(offsets[4], object.defaultPort);
  writer.writeLong(offsets[5], object.hdCode);
  writer.writeString(offsets[6], object.hrpBech32);
  writer.writeString(offsets[7], object.image);
  writer.writeString(offsets[8], object.magic);
  writer.writeString(offsets[9], object.name);
  writer.writeString(offsets[10], object.netVersionPrivateHex);
  writer.writeString(offsets[11], object.netVersionPublicHex);
  writer.writeString(offsets[12], object.peerSeedType);
  writer.writeString(offsets[13], object.peerSource);
  writer.writeString(offsets[14], object.symbol);
  writer.writeString(offsets[15], object.template);
  writer.writeDouble(offsets[16], object.usdPrice);
  writer.writeString(offsets[17], object.webId);
  writer.writeString(offsets[18], object.yahooFinance);
}

Coin _coinDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Coin();
  object.active = reader.readBoolOrNull(offsets[0]);
  object.blockZeroHash = reader.readStringOrNull(offsets[1]);
  object.contractHash = reader.readStringOrNull(offsets[2]);
  object.decimals = reader.readLongOrNull(offsets[3]);
  object.defaultPort = reader.readLongOrNull(offsets[4]);
  object.hdCode = reader.readLongOrNull(offsets[5]);
  object.hrpBech32 = reader.readStringOrNull(offsets[6]);
  object.id = id;
  object.image = reader.readStringOrNull(offsets[7]);
  object.magic = reader.readStringOrNull(offsets[8]);
  object.name = reader.readStringOrNull(offsets[9]);
  object.netVersionPrivateHex = reader.readStringOrNull(offsets[10]);
  object.netVersionPublicHex = reader.readStringOrNull(offsets[11]);
  object.peerSeedType = reader.readStringOrNull(offsets[12]);
  object.peerSource = reader.readStringOrNull(offsets[13]);
  object.symbol = reader.readStringOrNull(offsets[14]);
  object.template = reader.readStringOrNull(offsets[15]);
  object.usdPrice = reader.readDoubleOrNull(offsets[16]);
  object.webId = reader.readStringOrNull(offsets[17]);
  object.yahooFinance = reader.readStringOrNull(offsets[18]);
  return object;
}

P _coinDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _coinGetId(Coin object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _coinGetLinks(Coin object) {
  return [];
}

void _coinAttach(IsarCollection<dynamic> col, Id id, Coin object) {
  object.id = id;
}

extension CoinByIndex on IsarCollection<Coin> {
  Future<Coin?> getByName(String? name) {
    return getByIndex(r'name', [name]);
  }

  Coin? getByNameSync(String? name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String? name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String? name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<Coin?>> getAllByName(List<String?> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<Coin?> getAllByNameSync(List<String?> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String?> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String?> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(Coin object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(Coin object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<Coin> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<Coin> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension CoinQueryWhereSort on QueryBuilder<Coin, Coin, QWhere> {
  QueryBuilder<Coin, Coin, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CoinQueryWhere on QueryBuilder<Coin, Coin, QWhereClause> {
  QueryBuilder<Coin, Coin, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Coin, Coin, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Coin, Coin, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Coin, Coin, QAfterWhereClause> idBetween(
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

  QueryBuilder<Coin, Coin, QAfterWhereClause> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [null],
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterWhereClause> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterWhereClause> nameEqualTo(String? name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterWhereClause> nameNotEqualTo(String? name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CoinQueryFilter on QueryBuilder<Coin, Coin, QFilterCondition> {
  QueryBuilder<Coin, Coin, QAfterFilterCondition> activeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'active',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> activeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'active',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> activeEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'active',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'blockZeroHash',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'blockZeroHash',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockZeroHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockZeroHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockZeroHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockZeroHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blockZeroHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blockZeroHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockZeroHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockZeroHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockZeroHash',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> blockZeroHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockZeroHash',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contractHash',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contractHash',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contractHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contractHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contractHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contractHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contractHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contractHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contractHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contractHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contractHash',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> contractHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contractHash',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> decimalsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'decimals',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> decimalsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'decimals',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> decimalsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'decimals',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> decimalsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'decimals',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> decimalsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'decimals',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> decimalsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'decimals',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> defaultPortIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'defaultPort',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> defaultPortIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'defaultPort',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> defaultPortEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultPort',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> defaultPortGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultPort',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> defaultPortLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultPort',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> defaultPortBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultPort',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hdCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hdCode',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hdCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hdCode',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hdCodeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hdCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hdCodeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hdCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hdCodeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hdCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hdCodeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hdCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hrpBech32',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hrpBech32',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hrpBech32',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hrpBech32',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hrpBech32',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hrpBech32',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hrpBech32',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hrpBech32',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32Contains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hrpBech32',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32Matches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hrpBech32',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hrpBech32',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> hrpBech32IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hrpBech32',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Coin, Coin, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Coin, Coin, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'image',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'image',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'image',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'image',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'image',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'image',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> imageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'image',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'magic',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'magic',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'magic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'magic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'magic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'magic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'magic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'magic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'magic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'magic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'magic',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> magicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'magic',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPrivateHexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'netVersionPrivateHex',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition>
      netVersionPrivateHexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'netVersionPrivateHex',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPrivateHexEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'netVersionPrivateHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition>
      netVersionPrivateHexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'netVersionPrivateHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPrivateHexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'netVersionPrivateHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPrivateHexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'netVersionPrivateHex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition>
      netVersionPrivateHexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'netVersionPrivateHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPrivateHexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'netVersionPrivateHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPrivateHexContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'netVersionPrivateHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPrivateHexMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'netVersionPrivateHex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition>
      netVersionPrivateHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'netVersionPrivateHex',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition>
      netVersionPrivateHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'netVersionPrivateHex',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPublicHexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'netVersionPublicHex',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition>
      netVersionPublicHexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'netVersionPublicHex',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPublicHexEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'netVersionPublicHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition>
      netVersionPublicHexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'netVersionPublicHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPublicHexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'netVersionPublicHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPublicHexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'netVersionPublicHex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPublicHexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'netVersionPublicHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPublicHexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'netVersionPublicHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPublicHexContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'netVersionPublicHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPublicHexMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'netVersionPublicHex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> netVersionPublicHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'netVersionPublicHex',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition>
      netVersionPublicHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'netVersionPublicHex',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'peerSeedType',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'peerSeedType',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerSeedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerSeedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerSeedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerSeedType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'peerSeedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'peerSeedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'peerSeedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'peerSeedType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerSeedType',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSeedTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'peerSeedType',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'peerSource',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'peerSource',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerSource',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'peerSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'peerSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'peerSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'peerSource',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerSource',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> peerSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'peerSource',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'symbol',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'symbol',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'symbol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'symbol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'symbol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symbol',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> symbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'symbol',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'template',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'template',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'template',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'template',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'template',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'template',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> templateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'template',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> usdPriceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usdPrice',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> usdPriceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usdPrice',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> usdPriceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usdPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> usdPriceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usdPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> usdPriceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usdPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> usdPriceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usdPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'webId',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'webId',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'webId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'webId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'webId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'webId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'webId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'webId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'webId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'webId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'webId',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> webIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'webId',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'yahooFinance',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'yahooFinance',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yahooFinance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'yahooFinance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'yahooFinance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'yahooFinance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'yahooFinance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'yahooFinance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yahooFinance',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yahooFinance',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yahooFinance',
        value: '',
      ));
    });
  }

  QueryBuilder<Coin, Coin, QAfterFilterCondition> yahooFinanceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yahooFinance',
        value: '',
      ));
    });
  }
}

extension CoinQueryObject on QueryBuilder<Coin, Coin, QFilterCondition> {}

extension CoinQueryLinks on QueryBuilder<Coin, Coin, QFilterCondition> {}

extension CoinQuerySortBy on QueryBuilder<Coin, Coin, QSortBy> {
  QueryBuilder<Coin, Coin, QAfterSortBy> sortByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByBlockZeroHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockZeroHash', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByBlockZeroHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockZeroHash', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByContractHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contractHash', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByContractHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contractHash', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByDecimals() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decimals', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByDecimalsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decimals', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByDefaultPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPort', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByDefaultPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPort', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByHdCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdCode', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByHdCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdCode', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByHrpBech32() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrpBech32', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByHrpBech32Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrpBech32', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByMagic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'magic', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByMagicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'magic', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByNetVersionPrivateHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netVersionPrivateHex', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByNetVersionPrivateHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netVersionPrivateHex', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByNetVersionPublicHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netVersionPublicHex', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByNetVersionPublicHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netVersionPublicHex', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByPeerSeedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerSeedType', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByPeerSeedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerSeedType', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByPeerSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerSource', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByPeerSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerSource', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortBySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortBySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByTemplate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'template', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByTemplateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'template', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByUsdPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdPrice', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByUsdPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdPrice', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByWebId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webId', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByWebIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webId', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByYahooFinance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yahooFinance', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> sortByYahooFinanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yahooFinance', Sort.desc);
    });
  }
}

extension CoinQuerySortThenBy on QueryBuilder<Coin, Coin, QSortThenBy> {
  QueryBuilder<Coin, Coin, QAfterSortBy> thenByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByBlockZeroHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockZeroHash', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByBlockZeroHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockZeroHash', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByContractHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contractHash', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByContractHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contractHash', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByDecimals() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decimals', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByDecimalsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decimals', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByDefaultPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPort', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByDefaultPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultPort', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByHdCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdCode', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByHdCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdCode', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByHrpBech32() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrpBech32', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByHrpBech32Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrpBech32', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByMagic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'magic', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByMagicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'magic', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByNetVersionPrivateHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netVersionPrivateHex', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByNetVersionPrivateHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netVersionPrivateHex', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByNetVersionPublicHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netVersionPublicHex', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByNetVersionPublicHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netVersionPublicHex', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByPeerSeedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerSeedType', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByPeerSeedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerSeedType', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByPeerSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerSource', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByPeerSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerSource', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenBySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenBySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symbol', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByTemplate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'template', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByTemplateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'template', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByUsdPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdPrice', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByUsdPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdPrice', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByWebId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webId', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByWebIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webId', Sort.desc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByYahooFinance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yahooFinance', Sort.asc);
    });
  }

  QueryBuilder<Coin, Coin, QAfterSortBy> thenByYahooFinanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yahooFinance', Sort.desc);
    });
  }
}

extension CoinQueryWhereDistinct on QueryBuilder<Coin, Coin, QDistinct> {
  QueryBuilder<Coin, Coin, QDistinct> distinctByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'active');
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByBlockZeroHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockZeroHash',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByContractHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contractHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByDecimals() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'decimals');
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByDefaultPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultPort');
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByHdCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hdCode');
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByHrpBech32(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hrpBech32', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByImage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'image', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByMagic(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'magic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByNetVersionPrivateHex(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'netVersionPrivateHex',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByNetVersionPublicHex(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'netVersionPublicHex',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByPeerSeedType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerSeedType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByPeerSource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerSource', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctBySymbol(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'symbol', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByTemplate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'template', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByUsdPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usdPrice');
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByWebId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'webId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Coin, Coin, QDistinct> distinctByYahooFinance(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yahooFinance', caseSensitive: caseSensitive);
    });
  }
}

extension CoinQueryProperty on QueryBuilder<Coin, Coin, QQueryProperty> {
  QueryBuilder<Coin, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Coin, bool?, QQueryOperations> activeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'active');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> blockZeroHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockZeroHash');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> contractHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contractHash');
    });
  }

  QueryBuilder<Coin, int?, QQueryOperations> decimalsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'decimals');
    });
  }

  QueryBuilder<Coin, int?, QQueryOperations> defaultPortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultPort');
    });
  }

  QueryBuilder<Coin, int?, QQueryOperations> hdCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hdCode');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> hrpBech32Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hrpBech32');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> imageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'image');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> magicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'magic');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> netVersionPrivateHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'netVersionPrivateHex');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> netVersionPublicHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'netVersionPublicHex');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> peerSeedTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerSeedType');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> peerSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerSource');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> symbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'symbol');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> templateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'template');
    });
  }

  QueryBuilder<Coin, double?, QQueryOperations> usdPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usdPrice');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> webIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'webId');
    });
  }

  QueryBuilder<Coin, String?, QQueryOperations> yahooFinanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yahooFinance');
    });
  }
}

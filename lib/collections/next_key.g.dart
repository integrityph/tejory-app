// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_key.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNextKeyCollection on Isar {
  IsarCollection<NextKey> get nextKeys => this.collection();
}

const NextKeySchema = CollectionSchema(
  name: r'NextKey',
  id: -1204495448576995466,
  properties: {
    r'coin': PropertySchema(
      id: 0,
      name: r'coin',
      type: IsarType.long,
    ),
    r'nextKey': PropertySchema(
      id: 1,
      name: r'nextKey',
      type: IsarType.long,
    ),
    r'path': PropertySchema(
      id: 2,
      name: r'path',
      type: IsarType.string,
    ),
    r'wallet': PropertySchema(
      id: 3,
      name: r'wallet',
      type: IsarType.long,
    )
  },
  estimateSize: _nextKeyEstimateSize,
  serialize: _nextKeySerialize,
  deserialize: _nextKeyDeserialize,
  deserializeProp: _nextKeyDeserializeProp,
  idName: r'id',
  indexes: {
    r'path_coin_wallet': IndexSchema(
      id: 7062323147410399676,
      name: r'path_coin_wallet',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'path',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'coin',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'wallet',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _nextKeyGetId,
  getLinks: _nextKeyGetLinks,
  attach: _nextKeyAttach,
  version: '3.1.0+1',
);

int _nextKeyEstimateSize(
  NextKey object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.path;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _nextKeySerialize(
  NextKey object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.coin);
  writer.writeLong(offsets[1], object.nextKey);
  writer.writeString(offsets[2], object.path);
  writer.writeLong(offsets[3], object.wallet);
}

NextKey _nextKeyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NextKey();
  object.coin = reader.readLongOrNull(offsets[0]);
  object.id = id;
  object.nextKey = reader.readLongOrNull(offsets[1]);
  object.path = reader.readStringOrNull(offsets[2]);
  object.wallet = reader.readLongOrNull(offsets[3]);
  return object;
}

P _nextKeyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _nextKeyGetId(NextKey object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _nextKeyGetLinks(NextKey object) {
  return [];
}

void _nextKeyAttach(IsarCollection<dynamic> col, Id id, NextKey object) {
  object.id = id;
}

extension NextKeyByIndex on IsarCollection<NextKey> {
  Future<NextKey?> getByPathCoinWallet(String? path, int? coin, int? wallet) {
    return getByIndex(r'path_coin_wallet', [path, coin, wallet]);
  }

  NextKey? getByPathCoinWalletSync(String? path, int? coin, int? wallet) {
    return getByIndexSync(r'path_coin_wallet', [path, coin, wallet]);
  }

  Future<bool> deleteByPathCoinWallet(String? path, int? coin, int? wallet) {
    return deleteByIndex(r'path_coin_wallet', [path, coin, wallet]);
  }

  bool deleteByPathCoinWalletSync(String? path, int? coin, int? wallet) {
    return deleteByIndexSync(r'path_coin_wallet', [path, coin, wallet]);
  }

  Future<List<NextKey?>> getAllByPathCoinWallet(List<String?> pathValues,
      List<int?> coinValues, List<int?> walletValues) {
    final len = pathValues.length;
    assert(coinValues.length == len && walletValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pathValues[i], coinValues[i], walletValues[i]]);
    }

    return getAllByIndex(r'path_coin_wallet', values);
  }

  List<NextKey?> getAllByPathCoinWalletSync(List<String?> pathValues,
      List<int?> coinValues, List<int?> walletValues) {
    final len = pathValues.length;
    assert(coinValues.length == len && walletValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pathValues[i], coinValues[i], walletValues[i]]);
    }

    return getAllByIndexSync(r'path_coin_wallet', values);
  }

  Future<int> deleteAllByPathCoinWallet(List<String?> pathValues,
      List<int?> coinValues, List<int?> walletValues) {
    final len = pathValues.length;
    assert(coinValues.length == len && walletValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pathValues[i], coinValues[i], walletValues[i]]);
    }

    return deleteAllByIndex(r'path_coin_wallet', values);
  }

  int deleteAllByPathCoinWalletSync(List<String?> pathValues,
      List<int?> coinValues, List<int?> walletValues) {
    final len = pathValues.length;
    assert(coinValues.length == len && walletValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pathValues[i], coinValues[i], walletValues[i]]);
    }

    return deleteAllByIndexSync(r'path_coin_wallet', values);
  }

  Future<Id> putByPathCoinWallet(NextKey object) {
    return putByIndex(r'path_coin_wallet', object);
  }

  Id putByPathCoinWalletSync(NextKey object, {bool saveLinks = true}) {
    return putByIndexSync(r'path_coin_wallet', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPathCoinWallet(List<NextKey> objects) {
    return putAllByIndex(r'path_coin_wallet', objects);
  }

  List<Id> putAllByPathCoinWalletSync(List<NextKey> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'path_coin_wallet', objects,
        saveLinks: saveLinks);
  }
}

extension NextKeyQueryWhereSort on QueryBuilder<NextKey, NextKey, QWhere> {
  QueryBuilder<NextKey, NextKey, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NextKeyQueryWhere on QueryBuilder<NextKey, NextKey, QWhereClause> {
  QueryBuilder<NextKey, NextKey, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<NextKey, NextKey, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause> idBetween(
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

  QueryBuilder<NextKey, NextKey, QAfterWhereClause> pathIsNullAnyCoinWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_coin_wallet',
        value: [null],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathIsNotNullAnyCoinWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_coin_wallet',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause> pathEqualToAnyCoinWallet(
      String? path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_coin_wallet',
        value: [path],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause> pathNotEqualToAnyCoinWallet(
      String? path) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [],
              upper: [path],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [path],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [path],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [],
              upper: [path],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathEqualToCoinIsNullAnyWallet(String? path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_coin_wallet',
        value: [path, null],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathEqualToCoinIsNotNullAnyWallet(String? path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_coin_wallet',
        lower: [path, null],
        includeLower: false,
        upper: [
          path,
        ],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause> pathCoinEqualToAnyWallet(
      String? path, int? coin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_coin_wallet',
        value: [path, coin],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathEqualToCoinNotEqualToAnyWallet(String? path, int? coin) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [path],
              upper: [path, coin],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [path, coin],
              includeLower: false,
              upper: [path],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [path, coin],
              includeLower: false,
              upper: [path],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [path],
              upper: [path, coin],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathEqualToCoinGreaterThanAnyWallet(
    String? path,
    int? coin, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_coin_wallet',
        lower: [path, coin],
        includeLower: include,
        upper: [path],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathEqualToCoinLessThanAnyWallet(
    String? path,
    int? coin, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_coin_wallet',
        lower: [path],
        upper: [path, coin],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathEqualToCoinBetweenAnyWallet(
    String? path,
    int? lowerCoin,
    int? upperCoin, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_coin_wallet',
        lower: [path, lowerCoin],
        includeLower: includeLower,
        upper: [path, upperCoin],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause> pathCoinEqualToWalletIsNull(
      String? path, int? coin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_coin_wallet',
        value: [path, coin, null],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathCoinEqualToWalletIsNotNull(String? path, int? coin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_coin_wallet',
        lower: [path, coin, null],
        includeLower: false,
        upper: [
          path,
          coin,
        ],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause> pathCoinWalletEqualTo(
      String? path, int? coin, int? wallet) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_coin_wallet',
        value: [path, coin, wallet],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathCoinEqualToWalletNotEqualTo(String? path, int? coin, int? wallet) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [path, coin],
              upper: [path, coin, wallet],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [path, coin, wallet],
              includeLower: false,
              upper: [path, coin],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [path, coin, wallet],
              includeLower: false,
              upper: [path, coin],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_coin_wallet',
              lower: [path, coin],
              upper: [path, coin, wallet],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathCoinEqualToWalletGreaterThan(
    String? path,
    int? coin,
    int? wallet, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_coin_wallet',
        lower: [path, coin, wallet],
        includeLower: include,
        upper: [path, coin],
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathCoinEqualToWalletLessThan(
    String? path,
    int? coin,
    int? wallet, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_coin_wallet',
        lower: [path, coin],
        upper: [path, coin, wallet],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterWhereClause>
      pathCoinEqualToWalletBetween(
    String? path,
    int? coin,
    int? lowerWallet,
    int? upperWallet, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_coin_wallet',
        lower: [path, coin, lowerWallet],
        includeLower: includeLower,
        upper: [path, coin, upperWallet],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NextKeyQueryFilter
    on QueryBuilder<NextKey, NextKey, QFilterCondition> {
  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> coinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coin',
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> coinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coin',
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> coinEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coin',
        value: value,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> coinGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coin',
        value: value,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> coinLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coin',
        value: value,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> coinBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> idBetween(
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

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> nextKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextKey',
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> nextKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextKey',
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> nextKeyEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextKey',
        value: value,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> nextKeyGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextKey',
        value: value,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> nextKeyLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextKey',
        value: value,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> nextKeyBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'path',
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'path',
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'path',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'path',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> walletIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'wallet',
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> walletIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'wallet',
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> walletEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wallet',
        value: value,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> walletGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wallet',
        value: value,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> walletLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wallet',
        value: value,
      ));
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterFilterCondition> walletBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wallet',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NextKeyQueryObject
    on QueryBuilder<NextKey, NextKey, QFilterCondition> {}

extension NextKeyQueryLinks
    on QueryBuilder<NextKey, NextKey, QFilterCondition> {}

extension NextKeyQuerySortBy on QueryBuilder<NextKey, NextKey, QSortBy> {
  QueryBuilder<NextKey, NextKey, QAfterSortBy> sortByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.asc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> sortByCoinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.desc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> sortByNextKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextKey', Sort.asc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> sortByNextKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextKey', Sort.desc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> sortByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.asc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> sortByWalletDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.desc);
    });
  }
}

extension NextKeyQuerySortThenBy
    on QueryBuilder<NextKey, NextKey, QSortThenBy> {
  QueryBuilder<NextKey, NextKey, QAfterSortBy> thenByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.asc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> thenByCoinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.desc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> thenByNextKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextKey', Sort.asc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> thenByNextKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextKey', Sort.desc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> thenByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.asc);
    });
  }

  QueryBuilder<NextKey, NextKey, QAfterSortBy> thenByWalletDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.desc);
    });
  }
}

extension NextKeyQueryWhereDistinct
    on QueryBuilder<NextKey, NextKey, QDistinct> {
  QueryBuilder<NextKey, NextKey, QDistinct> distinctByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coin');
    });
  }

  QueryBuilder<NextKey, NextKey, QDistinct> distinctByNextKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextKey');
    });
  }

  QueryBuilder<NextKey, NextKey, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NextKey, NextKey, QDistinct> distinctByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wallet');
    });
  }
}

extension NextKeyQueryProperty
    on QueryBuilder<NextKey, NextKey, QQueryProperty> {
  QueryBuilder<NextKey, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NextKey, int?, QQueryOperations> coinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coin');
    });
  }

  QueryBuilder<NextKey, int?, QQueryOperations> nextKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextKey');
    });
  }

  QueryBuilder<NextKey, String?, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<NextKey, int?, QQueryOperations> walletProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wallet');
    });
  }
}

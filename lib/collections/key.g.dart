// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetKeyCollection on Isar {
  IsarCollection<Key> get keys => this.collection();
}

const KeySchema = CollectionSchema(
  name: r'Key',
  id: -3794925236929594043,
  properties: {
    r'chainCode': PropertySchema(
      id: 0,
      name: r'chainCode',
      type: IsarType.string,
    ),
    r'coin': PropertySchema(
      id: 1,
      name: r'coin',
      type: IsarType.long,
    ),
    r'path': PropertySchema(
      id: 2,
      name: r'path',
      type: IsarType.string,
    ),
    r'pubKey': PropertySchema(
      id: 3,
      name: r'pubKey',
      type: IsarType.string,
    ),
    r'wallet': PropertySchema(
      id: 4,
      name: r'wallet',
      type: IsarType.long,
    )
  },
  estimateSize: _keyEstimateSize,
  serialize: _keySerialize,
  deserialize: _keyDeserialize,
  deserializeProp: _keyDeserializeProp,
  idName: r'id',
  indexes: {
    r'path_wallet_coin': IndexSchema(
      id: -2098256463723959142,
      name: r'path_wallet_coin',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'path',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'wallet',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'coin',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _keyGetId,
  getLinks: _keyGetLinks,
  attach: _keyAttach,
  version: '3.1.0+1',
);

int _keyEstimateSize(
  Key object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.chainCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.path;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pubKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _keySerialize(
  Key object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.chainCode);
  writer.writeLong(offsets[1], object.coin);
  writer.writeString(offsets[2], object.path);
  writer.writeString(offsets[3], object.pubKey);
  writer.writeLong(offsets[4], object.wallet);
}

Key _keyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Key();
  object.chainCode = reader.readStringOrNull(offsets[0]);
  object.coin = reader.readLongOrNull(offsets[1]);
  object.id = id;
  object.path = reader.readStringOrNull(offsets[2]);
  object.pubKey = reader.readStringOrNull(offsets[3]);
  object.wallet = reader.readLongOrNull(offsets[4]);
  return object;
}

P _keyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _keyGetId(Key object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _keyGetLinks(Key object) {
  return [];
}

void _keyAttach(IsarCollection<dynamic> col, Id id, Key object) {
  object.id = id;
}

extension KeyByIndex on IsarCollection<Key> {
  Future<Key?> getByPathWalletCoin(String? path, int? wallet, int? coin) {
    return getByIndex(r'path_wallet_coin', [path, wallet, coin]);
  }

  Key? getByPathWalletCoinSync(String? path, int? wallet, int? coin) {
    return getByIndexSync(r'path_wallet_coin', [path, wallet, coin]);
  }

  Future<bool> deleteByPathWalletCoin(String? path, int? wallet, int? coin) {
    return deleteByIndex(r'path_wallet_coin', [path, wallet, coin]);
  }

  bool deleteByPathWalletCoinSync(String? path, int? wallet, int? coin) {
    return deleteByIndexSync(r'path_wallet_coin', [path, wallet, coin]);
  }

  Future<List<Key?>> getAllByPathWalletCoin(List<String?> pathValues,
      List<int?> walletValues, List<int?> coinValues) {
    final len = pathValues.length;
    assert(walletValues.length == len && coinValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pathValues[i], walletValues[i], coinValues[i]]);
    }

    return getAllByIndex(r'path_wallet_coin', values);
  }

  List<Key?> getAllByPathWalletCoinSync(List<String?> pathValues,
      List<int?> walletValues, List<int?> coinValues) {
    final len = pathValues.length;
    assert(walletValues.length == len && coinValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pathValues[i], walletValues[i], coinValues[i]]);
    }

    return getAllByIndexSync(r'path_wallet_coin', values);
  }

  Future<int> deleteAllByPathWalletCoin(List<String?> pathValues,
      List<int?> walletValues, List<int?> coinValues) {
    final len = pathValues.length;
    assert(walletValues.length == len && coinValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pathValues[i], walletValues[i], coinValues[i]]);
    }

    return deleteAllByIndex(r'path_wallet_coin', values);
  }

  int deleteAllByPathWalletCoinSync(List<String?> pathValues,
      List<int?> walletValues, List<int?> coinValues) {
    final len = pathValues.length;
    assert(walletValues.length == len && coinValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pathValues[i], walletValues[i], coinValues[i]]);
    }

    return deleteAllByIndexSync(r'path_wallet_coin', values);
  }

  Future<Id> putByPathWalletCoin(Key object) {
    return putByIndex(r'path_wallet_coin', object);
  }

  Id putByPathWalletCoinSync(Key object, {bool saveLinks = true}) {
    return putByIndexSync(r'path_wallet_coin', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPathWalletCoin(List<Key> objects) {
    return putAllByIndex(r'path_wallet_coin', objects);
  }

  List<Id> putAllByPathWalletCoinSync(List<Key> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'path_wallet_coin', objects,
        saveLinks: saveLinks);
  }
}

extension KeyQueryWhereSort on QueryBuilder<Key, Key, QWhere> {
  QueryBuilder<Key, Key, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension KeyQueryWhere on QueryBuilder<Key, Key, QWhereClause> {
  QueryBuilder<Key, Key, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Key, Key, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> idBetween(
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

  QueryBuilder<Key, Key, QAfterWhereClause> pathIsNullAnyWalletCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_wallet_coin',
        value: [null],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathIsNotNullAnyWalletCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_wallet_coin',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathEqualToAnyWalletCoin(
      String? path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_wallet_coin',
        value: [path],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathNotEqualToAnyWalletCoin(
      String? path) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [],
              upper: [path],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [path],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [path],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [],
              upper: [path],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathEqualToWalletIsNullAnyCoin(
      String? path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_wallet_coin',
        value: [path, null],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathEqualToWalletIsNotNullAnyCoin(
      String? path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_wallet_coin',
        lower: [path, null],
        includeLower: false,
        upper: [
          path,
        ],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathWalletEqualToAnyCoin(
      String? path, int? wallet) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_wallet_coin',
        value: [path, wallet],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathEqualToWalletNotEqualToAnyCoin(
      String? path, int? wallet) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [path],
              upper: [path, wallet],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [path, wallet],
              includeLower: false,
              upper: [path],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [path, wallet],
              includeLower: false,
              upper: [path],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [path],
              upper: [path, wallet],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathEqualToWalletGreaterThanAnyCoin(
    String? path,
    int? wallet, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_wallet_coin',
        lower: [path, wallet],
        includeLower: include,
        upper: [path],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathEqualToWalletLessThanAnyCoin(
    String? path,
    int? wallet, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_wallet_coin',
        lower: [path],
        upper: [path, wallet],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathEqualToWalletBetweenAnyCoin(
    String? path,
    int? lowerWallet,
    int? upperWallet, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_wallet_coin',
        lower: [path, lowerWallet],
        includeLower: includeLower,
        upper: [path, upperWallet],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathWalletEqualToCoinIsNull(
      String? path, int? wallet) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_wallet_coin',
        value: [path, wallet, null],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathWalletEqualToCoinIsNotNull(
      String? path, int? wallet) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_wallet_coin',
        lower: [path, wallet, null],
        includeLower: false,
        upper: [
          path,
          wallet,
        ],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathWalletCoinEqualTo(
      String? path, int? wallet, int? coin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path_wallet_coin',
        value: [path, wallet, coin],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathWalletEqualToCoinNotEqualTo(
      String? path, int? wallet, int? coin) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [path, wallet],
              upper: [path, wallet, coin],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [path, wallet, coin],
              includeLower: false,
              upper: [path, wallet],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [path, wallet, coin],
              includeLower: false,
              upper: [path, wallet],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path_wallet_coin',
              lower: [path, wallet],
              upper: [path, wallet, coin],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathWalletEqualToCoinGreaterThan(
    String? path,
    int? wallet,
    int? coin, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_wallet_coin',
        lower: [path, wallet, coin],
        includeLower: include,
        upper: [path, wallet],
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathWalletEqualToCoinLessThan(
    String? path,
    int? wallet,
    int? coin, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_wallet_coin',
        lower: [path, wallet],
        upper: [path, wallet, coin],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterWhereClause> pathWalletEqualToCoinBetween(
    String? path,
    int? wallet,
    int? lowerCoin,
    int? upperCoin, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path_wallet_coin',
        lower: [path, wallet, lowerCoin],
        includeLower: includeLower,
        upper: [path, wallet, upperCoin],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension KeyQueryFilter on QueryBuilder<Key, Key, QFilterCondition> {
  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chainCode',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chainCode',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chainCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chainCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chainCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chainCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chainCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chainCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chainCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chainCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chainCode',
        value: '',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> chainCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chainCode',
        value: '',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> coinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coin',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> coinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coin',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> coinEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coin',
        value: value,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> coinGreaterThan(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> coinLessThan(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> coinBetween(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> pathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'path',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'path',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pathEqualTo(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> pathGreaterThan(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> pathLessThan(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> pathBetween(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> pathStartsWith(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> pathEndsWith(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> pathContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pathMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'path',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pubKey',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pubKey',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pubKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pubKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pubKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pubKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pubKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pubKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pubKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pubKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pubKey',
        value: '',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> pubKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pubKey',
        value: '',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> walletIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'wallet',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> walletIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'wallet',
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> walletEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wallet',
        value: value,
      ));
    });
  }

  QueryBuilder<Key, Key, QAfterFilterCondition> walletGreaterThan(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> walletLessThan(
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

  QueryBuilder<Key, Key, QAfterFilterCondition> walletBetween(
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

extension KeyQueryObject on QueryBuilder<Key, Key, QFilterCondition> {}

extension KeyQueryLinks on QueryBuilder<Key, Key, QFilterCondition> {}

extension KeyQuerySortBy on QueryBuilder<Key, Key, QSortBy> {
  QueryBuilder<Key, Key, QAfterSortBy> sortByChainCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainCode', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> sortByChainCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainCode', Sort.desc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> sortByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> sortByCoinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.desc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> sortByPubKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pubKey', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> sortByPubKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pubKey', Sort.desc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> sortByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> sortByWalletDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.desc);
    });
  }
}

extension KeyQuerySortThenBy on QueryBuilder<Key, Key, QSortThenBy> {
  QueryBuilder<Key, Key, QAfterSortBy> thenByChainCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainCode', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenByChainCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chainCode', Sort.desc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenByCoinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.desc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenByPubKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pubKey', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenByPubKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pubKey', Sort.desc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.asc);
    });
  }

  QueryBuilder<Key, Key, QAfterSortBy> thenByWalletDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.desc);
    });
  }
}

extension KeyQueryWhereDistinct on QueryBuilder<Key, Key, QDistinct> {
  QueryBuilder<Key, Key, QDistinct> distinctByChainCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chainCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Key, Key, QDistinct> distinctByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coin');
    });
  }

  QueryBuilder<Key, Key, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Key, Key, QDistinct> distinctByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pubKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Key, Key, QDistinct> distinctByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wallet');
    });
  }
}

extension KeyQueryProperty on QueryBuilder<Key, Key, QQueryProperty> {
  QueryBuilder<Key, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Key, String?, QQueryOperations> chainCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chainCode');
    });
  }

  QueryBuilder<Key, int?, QQueryOperations> coinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coin');
    });
  }

  QueryBuilder<Key, String?, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<Key, String?, QQueryOperations> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pubKey');
    });
  }

  QueryBuilder<Key, int?, QQueryOperations> walletProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wallet');
    });
  }
}

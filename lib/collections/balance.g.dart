// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBalanceCollection on Isar {
  IsarCollection<Balance> get balances => this.collection();
}

const BalanceSchema = CollectionSchema(
  name: r'Balance',
  id: 1067837778200036490,
  properties: {
    r'coin': PropertySchema(
      id: 0,
      name: r'coin',
      type: IsarType.long,
    ),
    r'coinBalance': PropertySchema(
      id: 1,
      name: r'coinBalance',
      type: IsarType.long,
    ),
    r'fiatBalanceDC': PropertySchema(
      id: 2,
      name: r'fiatBalanceDC',
      type: IsarType.long,
    ),
    r'lastBlockUpdate': PropertySchema(
      id: 3,
      name: r'lastBlockUpdate',
      type: IsarType.string,
    ),
    r'lastUpdate': PropertySchema(
      id: 4,
      name: r'lastUpdate',
      type: IsarType.dateTime,
    ),
    r'usdBalance': PropertySchema(
      id: 5,
      name: r'usdBalance',
      type: IsarType.double,
    ),
    r'wallet': PropertySchema(
      id: 6,
      name: r'wallet',
      type: IsarType.long,
    )
  },
  estimateSize: _balanceEstimateSize,
  serialize: _balanceSerialize,
  deserialize: _balanceDeserialize,
  deserializeProp: _balanceDeserializeProp,
  idName: r'id',
  indexes: {
    r'coin_wallet': IndexSchema(
      id: -8455004919246086917,
      name: r'coin_wallet',
      unique: true,
      replace: false,
      properties: [
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
  getId: _balanceGetId,
  getLinks: _balanceGetLinks,
  attach: _balanceAttach,
  version: '3.1.0+1',
);

int _balanceEstimateSize(
  Balance object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.lastBlockUpdate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _balanceSerialize(
  Balance object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.coin);
  writer.writeLong(offsets[1], object.coinBalance);
  writer.writeLong(offsets[2], object.fiatBalanceDC);
  writer.writeString(offsets[3], object.lastBlockUpdate);
  writer.writeDateTime(offsets[4], object.lastUpdate);
  writer.writeDouble(offsets[5], object.usdBalance);
  writer.writeLong(offsets[6], object.wallet);
}

Balance _balanceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Balance();
  object.coin = reader.readLongOrNull(offsets[0]);
  object.coinBalance = reader.readLongOrNull(offsets[1]);
  object.fiatBalanceDC = reader.readLongOrNull(offsets[2]);
  object.id = id;
  object.lastBlockUpdate = reader.readStringOrNull(offsets[3]);
  object.lastUpdate = reader.readDateTimeOrNull(offsets[4]);
  object.usdBalance = reader.readDoubleOrNull(offsets[5]);
  object.wallet = reader.readLongOrNull(offsets[6]);
  return object;
}

P _balanceDeserializeProp<P>(
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
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _balanceGetId(Balance object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _balanceGetLinks(Balance object) {
  return [];
}

void _balanceAttach(IsarCollection<dynamic> col, Id id, Balance object) {
  object.id = id;
}

extension BalanceByIndex on IsarCollection<Balance> {
  Future<Balance?> getByCoinWallet(int? coin, int? wallet) {
    return getByIndex(r'coin_wallet', [coin, wallet]);
  }

  Balance? getByCoinWalletSync(int? coin, int? wallet) {
    return getByIndexSync(r'coin_wallet', [coin, wallet]);
  }

  Future<bool> deleteByCoinWallet(int? coin, int? wallet) {
    return deleteByIndex(r'coin_wallet', [coin, wallet]);
  }

  bool deleteByCoinWalletSync(int? coin, int? wallet) {
    return deleteByIndexSync(r'coin_wallet', [coin, wallet]);
  }

  Future<List<Balance?>> getAllByCoinWallet(
      List<int?> coinValues, List<int?> walletValues) {
    final len = coinValues.length;
    assert(walletValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([coinValues[i], walletValues[i]]);
    }

    return getAllByIndex(r'coin_wallet', values);
  }

  List<Balance?> getAllByCoinWalletSync(
      List<int?> coinValues, List<int?> walletValues) {
    final len = coinValues.length;
    assert(walletValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([coinValues[i], walletValues[i]]);
    }

    return getAllByIndexSync(r'coin_wallet', values);
  }

  Future<int> deleteAllByCoinWallet(
      List<int?> coinValues, List<int?> walletValues) {
    final len = coinValues.length;
    assert(walletValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([coinValues[i], walletValues[i]]);
    }

    return deleteAllByIndex(r'coin_wallet', values);
  }

  int deleteAllByCoinWalletSync(
      List<int?> coinValues, List<int?> walletValues) {
    final len = coinValues.length;
    assert(walletValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([coinValues[i], walletValues[i]]);
    }

    return deleteAllByIndexSync(r'coin_wallet', values);
  }

  Future<Id> putByCoinWallet(Balance object) {
    return putByIndex(r'coin_wallet', object);
  }

  Id putByCoinWalletSync(Balance object, {bool saveLinks = true}) {
    return putByIndexSync(r'coin_wallet', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCoinWallet(List<Balance> objects) {
    return putAllByIndex(r'coin_wallet', objects);
  }

  List<Id> putAllByCoinWalletSync(List<Balance> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'coin_wallet', objects, saveLinks: saveLinks);
  }
}

extension BalanceQueryWhereSort on QueryBuilder<Balance, Balance, QWhere> {
  QueryBuilder<Balance, Balance, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhere> anyCoinWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'coin_wallet'),
      );
    });
  }
}

extension BalanceQueryWhere on QueryBuilder<Balance, Balance, QWhereClause> {
  QueryBuilder<Balance, Balance, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Balance, Balance, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> idBetween(
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

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinIsNullAnyWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'coin_wallet',
        value: [null],
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinIsNotNullAnyWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'coin_wallet',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinEqualToAnyWallet(
      int? coin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'coin_wallet',
        value: [coin],
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinNotEqualToAnyWallet(
      int? coin) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'coin_wallet',
              lower: [],
              upper: [coin],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'coin_wallet',
              lower: [coin],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'coin_wallet',
              lower: [coin],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'coin_wallet',
              lower: [],
              upper: [coin],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinGreaterThanAnyWallet(
    int? coin, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'coin_wallet',
        lower: [coin],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinLessThanAnyWallet(
    int? coin, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'coin_wallet',
        lower: [],
        upper: [coin],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinBetweenAnyWallet(
    int? lowerCoin,
    int? upperCoin, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'coin_wallet',
        lower: [lowerCoin],
        includeLower: includeLower,
        upper: [upperCoin],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinEqualToWalletIsNull(
      int? coin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'coin_wallet',
        value: [coin, null],
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinEqualToWalletIsNotNull(
      int? coin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'coin_wallet',
        lower: [coin, null],
        includeLower: false,
        upper: [
          coin,
        ],
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinWalletEqualTo(
      int? coin, int? wallet) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'coin_wallet',
        value: [coin, wallet],
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinEqualToWalletNotEqualTo(
      int? coin, int? wallet) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'coin_wallet',
              lower: [coin],
              upper: [coin, wallet],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'coin_wallet',
              lower: [coin, wallet],
              includeLower: false,
              upper: [coin],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'coin_wallet',
              lower: [coin, wallet],
              includeLower: false,
              upper: [coin],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'coin_wallet',
              lower: [coin],
              upper: [coin, wallet],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause>
      coinEqualToWalletGreaterThan(
    int? coin,
    int? wallet, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'coin_wallet',
        lower: [coin, wallet],
        includeLower: include,
        upper: [coin],
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinEqualToWalletLessThan(
    int? coin,
    int? wallet, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'coin_wallet',
        lower: [coin],
        upper: [coin, wallet],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterWhereClause> coinEqualToWalletBetween(
    int? coin,
    int? lowerWallet,
    int? upperWallet, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'coin_wallet',
        lower: [coin, lowerWallet],
        includeLower: includeLower,
        upper: [coin, upperWallet],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BalanceQueryFilter
    on QueryBuilder<Balance, Balance, QFilterCondition> {
  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coin',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coin',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coin',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinGreaterThan(
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

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinLessThan(
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

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinBetween(
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

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinBalanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coinBalance',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinBalanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coinBalance',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinBalanceEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coinBalance',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinBalanceGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coinBalance',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinBalanceLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coinBalance',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> coinBalanceBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coinBalance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> fiatBalanceDCIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fiatBalanceDC',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition>
      fiatBalanceDCIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fiatBalanceDC',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> fiatBalanceDCEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fiatBalanceDC',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition>
      fiatBalanceDCGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fiatBalanceDC',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> fiatBalanceDCLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fiatBalanceDC',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> fiatBalanceDCBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fiatBalanceDC',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Balance, Balance, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Balance, Balance, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Balance, Balance, QAfterFilterCondition>
      lastBlockUpdateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastBlockUpdate',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition>
      lastBlockUpdateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastBlockUpdate',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastBlockUpdateEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastBlockUpdate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition>
      lastBlockUpdateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastBlockUpdate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastBlockUpdateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastBlockUpdate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastBlockUpdateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastBlockUpdate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition>
      lastBlockUpdateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastBlockUpdate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastBlockUpdateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastBlockUpdate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastBlockUpdateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastBlockUpdate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastBlockUpdateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastBlockUpdate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition>
      lastBlockUpdateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastBlockUpdate',
        value: '',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition>
      lastBlockUpdateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastBlockUpdate',
        value: '',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastUpdateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdate',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastUpdateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdate',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastUpdateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdate',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastUpdateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdate',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastUpdateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdate',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> lastUpdateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> usdBalanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usdBalance',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> usdBalanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usdBalance',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> usdBalanceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usdBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> usdBalanceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usdBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> usdBalanceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usdBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> usdBalanceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usdBalance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> walletIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'wallet',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> walletIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'wallet',
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> walletEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wallet',
        value: value,
      ));
    });
  }

  QueryBuilder<Balance, Balance, QAfterFilterCondition> walletGreaterThan(
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

  QueryBuilder<Balance, Balance, QAfterFilterCondition> walletLessThan(
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

  QueryBuilder<Balance, Balance, QAfterFilterCondition> walletBetween(
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

extension BalanceQueryObject
    on QueryBuilder<Balance, Balance, QFilterCondition> {}

extension BalanceQueryLinks
    on QueryBuilder<Balance, Balance, QFilterCondition> {}

extension BalanceQuerySortBy on QueryBuilder<Balance, Balance, QSortBy> {
  QueryBuilder<Balance, Balance, QAfterSortBy> sortByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByCoinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByCoinBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coinBalance', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByCoinBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coinBalance', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByFiatBalanceDC() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiatBalanceDC', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByFiatBalanceDCDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiatBalanceDC', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByLastBlockUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBlockUpdate', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByLastBlockUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBlockUpdate', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByLastUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByLastUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByUsdBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdBalance', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByUsdBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdBalance', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> sortByWalletDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.desc);
    });
  }
}

extension BalanceQuerySortThenBy
    on QueryBuilder<Balance, Balance, QSortThenBy> {
  QueryBuilder<Balance, Balance, QAfterSortBy> thenByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByCoinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByCoinBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coinBalance', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByCoinBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coinBalance', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByFiatBalanceDC() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiatBalanceDC', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByFiatBalanceDCDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiatBalanceDC', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByLastBlockUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBlockUpdate', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByLastBlockUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBlockUpdate', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByLastUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByLastUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByUsdBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdBalance', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByUsdBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdBalance', Sort.desc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.asc);
    });
  }

  QueryBuilder<Balance, Balance, QAfterSortBy> thenByWalletDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.desc);
    });
  }
}

extension BalanceQueryWhereDistinct
    on QueryBuilder<Balance, Balance, QDistinct> {
  QueryBuilder<Balance, Balance, QDistinct> distinctByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coin');
    });
  }

  QueryBuilder<Balance, Balance, QDistinct> distinctByCoinBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coinBalance');
    });
  }

  QueryBuilder<Balance, Balance, QDistinct> distinctByFiatBalanceDC() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fiatBalanceDC');
    });
  }

  QueryBuilder<Balance, Balance, QDistinct> distinctByLastBlockUpdate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBlockUpdate',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balance, Balance, QDistinct> distinctByLastUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdate');
    });
  }

  QueryBuilder<Balance, Balance, QDistinct> distinctByUsdBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usdBalance');
    });
  }

  QueryBuilder<Balance, Balance, QDistinct> distinctByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wallet');
    });
  }
}

extension BalanceQueryProperty
    on QueryBuilder<Balance, Balance, QQueryProperty> {
  QueryBuilder<Balance, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Balance, int?, QQueryOperations> coinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coin');
    });
  }

  QueryBuilder<Balance, int?, QQueryOperations> coinBalanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coinBalance');
    });
  }

  QueryBuilder<Balance, int?, QQueryOperations> fiatBalanceDCProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fiatBalanceDC');
    });
  }

  QueryBuilder<Balance, String?, QQueryOperations> lastBlockUpdateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBlockUpdate');
    });
  }

  QueryBuilder<Balance, DateTime?, QQueryOperations> lastUpdateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdate');
    });
  }

  QueryBuilder<Balance, double?, QQueryOperations> usdBalanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usdBalance');
    });
  }

  QueryBuilder<Balance, int?, QQueryOperations> walletProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wallet');
    });
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tx.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTxDBCollection on Isar {
  IsarCollection<TxDB> get txDBs => this.collection();
}

const TxDBSchema = CollectionSchema(
  name: r'TxDB',
  id: -7333929017071856214,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.long,
    ),
    r'blockHash': PropertySchema(
      id: 1,
      name: r'blockHash',
      type: IsarType.string,
    ),
    r'coin': PropertySchema(
      id: 2,
      name: r'coin',
      type: IsarType.long,
    ),
    r'confirmed': PropertySchema(
      id: 3,
      name: r'confirmed',
      type: IsarType.bool,
    ),
    r'failed': PropertySchema(
      id: 4,
      name: r'failed',
      type: IsarType.bool,
    ),
    r'fee': PropertySchema(
      id: 5,
      name: r'fee',
      type: IsarType.long,
    ),
    r'hash': PropertySchema(
      id: 6,
      name: r'hash',
      type: IsarType.string,
    ),
    r'hdPath': PropertySchema(
      id: 7,
      name: r'hdPath',
      type: IsarType.string,
    ),
    r'isDeposit': PropertySchema(
      id: 8,
      name: r'isDeposit',
      type: IsarType.bool,
    ),
    r'lockingScript': PropertySchema(
      id: 9,
      name: r'lockingScript',
      type: IsarType.string,
    ),
    r'lockingScriptType': PropertySchema(
      id: 10,
      name: r'lockingScriptType',
      type: IsarType.string,
    ),
    r'outputIndex': PropertySchema(
      id: 11,
      name: r'outputIndex',
      type: IsarType.long,
    ),
    r'spendingTxHash': PropertySchema(
      id: 12,
      name: r'spendingTxHash',
      type: IsarType.string,
    ),
    r'spent': PropertySchema(
      id: 13,
      name: r'spent',
      type: IsarType.bool,
    ),
    r'time': PropertySchema(
      id: 14,
      name: r'time',
      type: IsarType.dateTime,
    ),
    r'usdAmount': PropertySchema(
      id: 15,
      name: r'usdAmount',
      type: IsarType.double,
    ),
    r'verified': PropertySchema(
      id: 16,
      name: r'verified',
      type: IsarType.bool,
    ),
    r'wallet': PropertySchema(
      id: 17,
      name: r'wallet',
      type: IsarType.long,
    )
  },
  estimateSize: _txDBEstimateSize,
  serialize: _txDBSerialize,
  deserialize: _txDBDeserialize,
  deserializeProp: _txDBDeserializeProp,
  idName: r'id',
  indexes: {
    r'hash_coin_outputIndex': IndexSchema(
      id: -4063429889069788556,
      name: r'hash_coin_outputIndex',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'hash',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'coin',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'outputIndex',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _txDBGetId,
  getLinks: _txDBGetLinks,
  attach: _txDBAttach,
  version: '3.1.0+1',
);

int _txDBEstimateSize(
  TxDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.blockHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.hash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.hdPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lockingScript;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lockingScriptType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.spendingTxHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _txDBSerialize(
  TxDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amount);
  writer.writeString(offsets[1], object.blockHash);
  writer.writeLong(offsets[2], object.coin);
  writer.writeBool(offsets[3], object.confirmed);
  writer.writeBool(offsets[4], object.failed);
  writer.writeLong(offsets[5], object.fee);
  writer.writeString(offsets[6], object.hash);
  writer.writeString(offsets[7], object.hdPath);
  writer.writeBool(offsets[8], object.isDeposit);
  writer.writeString(offsets[9], object.lockingScript);
  writer.writeString(offsets[10], object.lockingScriptType);
  writer.writeLong(offsets[11], object.outputIndex);
  writer.writeString(offsets[12], object.spendingTxHash);
  writer.writeBool(offsets[13], object.spent);
  writer.writeDateTime(offsets[14], object.time);
  writer.writeDouble(offsets[15], object.usdAmount);
  writer.writeBool(offsets[16], object.verified);
  writer.writeLong(offsets[17], object.wallet);
}

TxDB _txDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TxDB();
  object.amount = reader.readLongOrNull(offsets[0]);
  object.blockHash = reader.readStringOrNull(offsets[1]);
  object.coin = reader.readLongOrNull(offsets[2]);
  object.confirmed = reader.readBoolOrNull(offsets[3]);
  object.failed = reader.readBoolOrNull(offsets[4]);
  object.fee = reader.readLongOrNull(offsets[5]);
  object.hash = reader.readStringOrNull(offsets[6]);
  object.hdPath = reader.readStringOrNull(offsets[7]);
  object.id = id;
  object.isDeposit = reader.readBoolOrNull(offsets[8]);
  object.lockingScript = reader.readStringOrNull(offsets[9]);
  object.lockingScriptType = reader.readStringOrNull(offsets[10]);
  object.outputIndex = reader.readLongOrNull(offsets[11]);
  object.spendingTxHash = reader.readStringOrNull(offsets[12]);
  object.spent = reader.readBoolOrNull(offsets[13]);
  object.time = reader.readDateTimeOrNull(offsets[14]);
  object.usdAmount = reader.readDoubleOrNull(offsets[15]);
  object.verified = reader.readBoolOrNull(offsets[16]);
  object.wallet = reader.readLongOrNull(offsets[17]);
  return object;
}

P _txDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readBoolOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readBoolOrNull(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readDoubleOrNull(offset)) as P;
    case 16:
      return (reader.readBoolOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _txDBGetId(TxDB object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _txDBGetLinks(TxDB object) {
  return [];
}

void _txDBAttach(IsarCollection<dynamic> col, Id id, TxDB object) {
  object.id = id;
}

extension TxDBByIndex on IsarCollection<TxDB> {
  Future<TxDB?> getByHashCoinOutputIndex(
      String? hash, int? coin, int? outputIndex) {
    return getByIndex(r'hash_coin_outputIndex', [hash, coin, outputIndex]);
  }

  TxDB? getByHashCoinOutputIndexSync(
      String? hash, int? coin, int? outputIndex) {
    return getByIndexSync(r'hash_coin_outputIndex', [hash, coin, outputIndex]);
  }

  Future<bool> deleteByHashCoinOutputIndex(
      String? hash, int? coin, int? outputIndex) {
    return deleteByIndex(r'hash_coin_outputIndex', [hash, coin, outputIndex]);
  }

  bool deleteByHashCoinOutputIndexSync(
      String? hash, int? coin, int? outputIndex) {
    return deleteByIndexSync(
        r'hash_coin_outputIndex', [hash, coin, outputIndex]);
  }

  Future<List<TxDB?>> getAllByHashCoinOutputIndex(List<String?> hashValues,
      List<int?> coinValues, List<int?> outputIndexValues) {
    final len = hashValues.length;
    assert(coinValues.length == len && outputIndexValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([hashValues[i], coinValues[i], outputIndexValues[i]]);
    }

    return getAllByIndex(r'hash_coin_outputIndex', values);
  }

  List<TxDB?> getAllByHashCoinOutputIndexSync(List<String?> hashValues,
      List<int?> coinValues, List<int?> outputIndexValues) {
    final len = hashValues.length;
    assert(coinValues.length == len && outputIndexValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([hashValues[i], coinValues[i], outputIndexValues[i]]);
    }

    return getAllByIndexSync(r'hash_coin_outputIndex', values);
  }

  Future<int> deleteAllByHashCoinOutputIndex(List<String?> hashValues,
      List<int?> coinValues, List<int?> outputIndexValues) {
    final len = hashValues.length;
    assert(coinValues.length == len && outputIndexValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([hashValues[i], coinValues[i], outputIndexValues[i]]);
    }

    return deleteAllByIndex(r'hash_coin_outputIndex', values);
  }

  int deleteAllByHashCoinOutputIndexSync(List<String?> hashValues,
      List<int?> coinValues, List<int?> outputIndexValues) {
    final len = hashValues.length;
    assert(coinValues.length == len && outputIndexValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([hashValues[i], coinValues[i], outputIndexValues[i]]);
    }

    return deleteAllByIndexSync(r'hash_coin_outputIndex', values);
  }

  Future<Id> putByHashCoinOutputIndex(TxDB object) {
    return putByIndex(r'hash_coin_outputIndex', object);
  }

  Id putByHashCoinOutputIndexSync(TxDB object, {bool saveLinks = true}) {
    return putByIndexSync(r'hash_coin_outputIndex', object,
        saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByHashCoinOutputIndex(List<TxDB> objects) {
    return putAllByIndex(r'hash_coin_outputIndex', objects);
  }

  List<Id> putAllByHashCoinOutputIndexSync(List<TxDB> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'hash_coin_outputIndex', objects,
        saveLinks: saveLinks);
  }
}

extension TxDBQueryWhereSort on QueryBuilder<TxDB, TxDB, QWhere> {
  QueryBuilder<TxDB, TxDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TxDBQueryWhere on QueryBuilder<TxDB, TxDB, QWhereClause> {
  QueryBuilder<TxDB, TxDB, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> idBetween(
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

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> hashIsNullAnyCoinOutputIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hash_coin_outputIndex',
        value: [null],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashIsNotNullAnyCoinOutputIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hash_coin_outputIndex',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> hashEqualToAnyCoinOutputIndex(
      String? hash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hash_coin_outputIndex',
        value: [hash],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> hashNotEqualToAnyCoinOutputIndex(
      String? hash) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [],
              upper: [hash],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [hash],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [hash],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [],
              upper: [hash],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashEqualToCoinIsNullAnyOutputIndex(String? hash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hash_coin_outputIndex',
        value: [hash, null],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashEqualToCoinIsNotNullAnyOutputIndex(String? hash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hash_coin_outputIndex',
        lower: [hash, null],
        includeLower: false,
        upper: [
          hash,
        ],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> hashCoinEqualToAnyOutputIndex(
      String? hash, int? coin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hash_coin_outputIndex',
        value: [hash, coin],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashEqualToCoinNotEqualToAnyOutputIndex(String? hash, int? coin) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [hash],
              upper: [hash, coin],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [hash, coin],
              includeLower: false,
              upper: [hash],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [hash, coin],
              includeLower: false,
              upper: [hash],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [hash],
              upper: [hash, coin],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashEqualToCoinGreaterThanAnyOutputIndex(
    String? hash,
    int? coin, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hash_coin_outputIndex',
        lower: [hash, coin],
        includeLower: include,
        upper: [hash],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashEqualToCoinLessThanAnyOutputIndex(
    String? hash,
    int? coin, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hash_coin_outputIndex',
        lower: [hash],
        upper: [hash, coin],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashEqualToCoinBetweenAnyOutputIndex(
    String? hash,
    int? lowerCoin,
    int? upperCoin, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hash_coin_outputIndex',
        lower: [hash, lowerCoin],
        includeLower: includeLower,
        upper: [hash, upperCoin],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> hashCoinEqualToOutputIndexIsNull(
      String? hash, int? coin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hash_coin_outputIndex',
        value: [hash, coin, null],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashCoinEqualToOutputIndexIsNotNull(String? hash, int? coin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hash_coin_outputIndex',
        lower: [hash, coin, null],
        includeLower: false,
        upper: [
          hash,
          coin,
        ],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> hashCoinOutputIndexEqualTo(
      String? hash, int? coin, int? outputIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hash_coin_outputIndex',
        value: [hash, coin, outputIndex],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashCoinEqualToOutputIndexNotEqualTo(
          String? hash, int? coin, int? outputIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [hash, coin],
              upper: [hash, coin, outputIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [hash, coin, outputIndex],
              includeLower: false,
              upper: [hash, coin],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [hash, coin, outputIndex],
              includeLower: false,
              upper: [hash, coin],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hash_coin_outputIndex',
              lower: [hash, coin],
              upper: [hash, coin, outputIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashCoinEqualToOutputIndexGreaterThan(
    String? hash,
    int? coin,
    int? outputIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hash_coin_outputIndex',
        lower: [hash, coin, outputIndex],
        includeLower: include,
        upper: [hash, coin],
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause>
      hashCoinEqualToOutputIndexLessThan(
    String? hash,
    int? coin,
    int? outputIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hash_coin_outputIndex',
        lower: [hash, coin],
        upper: [hash, coin, outputIndex],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterWhereClause> hashCoinEqualToOutputIndexBetween(
    String? hash,
    int? coin,
    int? lowerOutputIndex,
    int? upperOutputIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'hash_coin_outputIndex',
        lower: [hash, coin, lowerOutputIndex],
        includeLower: includeLower,
        upper: [hash, coin, upperOutputIndex],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TxDBQueryFilter on QueryBuilder<TxDB, TxDB, QFilterCondition> {
  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> amountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> amountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> amountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> amountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> amountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> amountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'blockHash',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'blockHash',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blockHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blockHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockHash',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> blockHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockHash',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> coinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coin',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> coinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coin',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> coinEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coin',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> coinGreaterThan(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> coinLessThan(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> coinBetween(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> confirmedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'confirmed',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> confirmedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'confirmed',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> confirmedEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confirmed',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> failedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'failed',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> failedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'failed',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> failedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failed',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> feeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fee',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> feeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fee',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> feeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fee',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> feeGreaterThan(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> feeLessThan(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> feeBetween(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hash',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hash',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hdPath',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hdPath',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hdPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hdPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hdPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hdPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hdPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hdPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hdPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hdPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hdPath',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> hdPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hdPath',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> isDepositIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isDeposit',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> isDepositIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isDeposit',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> isDepositEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeposit',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lockingScript',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lockingScript',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lockingScript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lockingScript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lockingScript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lockingScript',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lockingScript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lockingScript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lockingScript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lockingScript',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lockingScript',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lockingScript',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lockingScriptType',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lockingScriptType',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lockingScriptType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lockingScriptType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lockingScriptType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lockingScriptType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lockingScriptType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lockingScriptType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lockingScriptType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lockingScriptType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> lockingScriptTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lockingScriptType',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition>
      lockingScriptTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lockingScriptType',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> outputIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'outputIndex',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> outputIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'outputIndex',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> outputIndexEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outputIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> outputIndexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outputIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> outputIndexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outputIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> outputIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outputIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'spendingTxHash',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'spendingTxHash',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spendingTxHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spendingTxHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spendingTxHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spendingTxHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'spendingTxHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'spendingTxHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'spendingTxHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'spendingTxHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spendingTxHash',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spendingTxHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'spendingTxHash',
        value: '',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'spent',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'spent',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> spentEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spent',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> timeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'time',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> timeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'time',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> timeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> timeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> timeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> timeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> usdAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usdAmount',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> usdAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usdAmount',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> usdAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usdAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> usdAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usdAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> usdAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usdAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> usdAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usdAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> verifiedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'verified',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> verifiedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'verified',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> verifiedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verified',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> walletIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'wallet',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> walletIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'wallet',
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> walletEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wallet',
        value: value,
      ));
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> walletGreaterThan(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> walletLessThan(
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

  QueryBuilder<TxDB, TxDB, QAfterFilterCondition> walletBetween(
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

extension TxDBQueryObject on QueryBuilder<TxDB, TxDB, QFilterCondition> {}

extension TxDBQueryLinks on QueryBuilder<TxDB, TxDB, QFilterCondition> {}

extension TxDBQuerySortBy on QueryBuilder<TxDB, TxDB, QSortBy> {
  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByBlockHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockHash', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByBlockHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockHash', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByCoinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByHdPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdPath', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByHdPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdPath', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByIsDeposit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeposit', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByIsDepositDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeposit', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByLockingScript() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockingScript', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByLockingScriptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockingScript', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByLockingScriptType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockingScriptType', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByLockingScriptTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockingScriptType', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByOutputIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputIndex', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByOutputIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputIndex', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortBySpendingTxHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spendingTxHash', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortBySpendingTxHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spendingTxHash', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortBySpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spent', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortBySpentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spent', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByUsdAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdAmount', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByUsdAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdAmount', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> sortByWalletDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.desc);
    });
  }
}

extension TxDBQuerySortThenBy on QueryBuilder<TxDB, TxDB, QSortThenBy> {
  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByBlockHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockHash', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByBlockHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockHash', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByCoinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coin', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByHdPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdPath', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByHdPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hdPath', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByIsDeposit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeposit', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByIsDepositDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeposit', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByLockingScript() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockingScript', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByLockingScriptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockingScript', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByLockingScriptType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockingScriptType', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByLockingScriptTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockingScriptType', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByOutputIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputIndex', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByOutputIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputIndex', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenBySpendingTxHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spendingTxHash', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenBySpendingTxHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spendingTxHash', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenBySpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spent', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenBySpentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spent', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByUsdAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdAmount', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByUsdAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usdAmount', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.asc);
    });
  }

  QueryBuilder<TxDB, TxDB, QAfterSortBy> thenByWalletDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallet', Sort.desc);
    });
  }
}

extension TxDBQueryWhereDistinct on QueryBuilder<TxDB, TxDB, QDistinct> {
  QueryBuilder<TxDB, TxDB, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByBlockHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByCoin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coin');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confirmed');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failed');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fee');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByHdPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hdPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByIsDeposit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeposit');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByLockingScript(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lockingScript',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByLockingScriptType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lockingScriptType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByOutputIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outputIndex');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctBySpendingTxHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spendingTxHash',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctBySpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spent');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByUsdAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usdAmount');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verified');
    });
  }

  QueryBuilder<TxDB, TxDB, QDistinct> distinctByWallet() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wallet');
    });
  }
}

extension TxDBQueryProperty on QueryBuilder<TxDB, TxDB, QQueryProperty> {
  QueryBuilder<TxDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TxDB, int?, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<TxDB, String?, QQueryOperations> blockHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockHash');
    });
  }

  QueryBuilder<TxDB, int?, QQueryOperations> coinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coin');
    });
  }

  QueryBuilder<TxDB, bool?, QQueryOperations> confirmedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confirmed');
    });
  }

  QueryBuilder<TxDB, bool?, QQueryOperations> failedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failed');
    });
  }

  QueryBuilder<TxDB, int?, QQueryOperations> feeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fee');
    });
  }

  QueryBuilder<TxDB, String?, QQueryOperations> hashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hash');
    });
  }

  QueryBuilder<TxDB, String?, QQueryOperations> hdPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hdPath');
    });
  }

  QueryBuilder<TxDB, bool?, QQueryOperations> isDepositProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeposit');
    });
  }

  QueryBuilder<TxDB, String?, QQueryOperations> lockingScriptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lockingScript');
    });
  }

  QueryBuilder<TxDB, String?, QQueryOperations> lockingScriptTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lockingScriptType');
    });
  }

  QueryBuilder<TxDB, int?, QQueryOperations> outputIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outputIndex');
    });
  }

  QueryBuilder<TxDB, String?, QQueryOperations> spendingTxHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spendingTxHash');
    });
  }

  QueryBuilder<TxDB, bool?, QQueryOperations> spentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spent');
    });
  }

  QueryBuilder<TxDB, DateTime?, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<TxDB, double?, QQueryOperations> usdAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usdAmount');
    });
  }

  QueryBuilder<TxDB, bool?, QQueryOperations> verifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verified');
    });
  }

  QueryBuilder<TxDB, int?, QQueryOperations> walletProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wallet');
    });
  }
}

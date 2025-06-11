// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWalletDBCollection on Isar {
  IsarCollection<WalletDB> get walletDBs => this.collection();
}

const WalletDBSchema = CollectionSchema(
  name: r'WalletDB',
  id: -5190010613619085973,
  properties: {
    r'easyImport': PropertySchema(
      id: 0,
      name: r'easyImport',
      type: IsarType.bool,
    ),
    r'extendedPrivKey': PropertySchema(
      id: 1,
      name: r'extendedPrivKey',
      type: IsarType.string,
    ),
    r'fingerPrint': PropertySchema(
      id: 2,
      name: r'fingerPrint',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'serialNumber': PropertySchema(
      id: 4,
      name: r'serialNumber',
      type: IsarType.string,
    ),
    r'startYear': PropertySchema(
      id: 5,
      name: r'startYear',
      type: IsarType.dateTime,
    ),
    r'type': PropertySchema(
      id: 6,
      name: r'type',
      type: IsarType.byte,
      enumMap: _WalletDBtypeEnumValueMap,
    )
  },
  estimateSize: _walletDBEstimateSize,
  serialize: _walletDBSerialize,
  deserialize: _walletDBDeserialize,
  deserializeProp: _walletDBDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _walletDBGetId,
  getLinks: _walletDBGetLinks,
  attach: _walletDBAttach,
  version: '3.1.0+1',
);

int _walletDBEstimateSize(
  WalletDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.extendedPrivKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fingerPrint;
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
    final value = object.serialNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _walletDBSerialize(
  WalletDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.easyImport);
  writer.writeString(offsets[1], object.extendedPrivKey);
  writer.writeString(offsets[2], object.fingerPrint);
  writer.writeString(offsets[3], object.name);
  writer.writeString(offsets[4], object.serialNumber);
  writer.writeDateTime(offsets[5], object.startYear);
  writer.writeByte(offsets[6], object.type.index);
}

WalletDB _walletDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WalletDB();
  object.easyImport = reader.readBoolOrNull(offsets[0]);
  object.extendedPrivKey = reader.readStringOrNull(offsets[1]);
  object.fingerPrint = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.name = reader.readStringOrNull(offsets[3]);
  object.serialNumber = reader.readStringOrNull(offsets[4]);
  object.startYear = reader.readDateTimeOrNull(offsets[5]);
  object.type = _WalletDBtypeValueEnumMap[reader.readByteOrNull(offsets[6])] ??
      WalletType.unknown;
  return object;
}

P _walletDBDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (_WalletDBtypeValueEnumMap[reader.readByteOrNull(offset)] ??
          WalletType.unknown) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _WalletDBtypeEnumValueMap = {
  'unknown': 0,
  'phone': 1,
  'tejoryCard': 2,
};
const _WalletDBtypeValueEnumMap = {
  0: WalletType.unknown,
  1: WalletType.phone,
  2: WalletType.tejoryCard,
};

Id _walletDBGetId(WalletDB object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _walletDBGetLinks(WalletDB object) {
  return [];
}

void _walletDBAttach(IsarCollection<dynamic> col, Id id, WalletDB object) {
  object.id = id;
}

extension WalletDBQueryWhereSort on QueryBuilder<WalletDB, WalletDB, QWhere> {
  QueryBuilder<WalletDB, WalletDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WalletDBQueryWhere on QueryBuilder<WalletDB, WalletDB, QWhereClause> {
  QueryBuilder<WalletDB, WalletDB, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<WalletDB, WalletDB, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterWhereClause> idBetween(
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
}

extension WalletDBQueryFilter
    on QueryBuilder<WalletDB, WalletDB, QFilterCondition> {
  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> easyImportIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'easyImport',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      easyImportIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'easyImport',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> easyImportEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'easyImport',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'extendedPrivKey',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'extendedPrivKey',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extendedPrivKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'extendedPrivKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'extendedPrivKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'extendedPrivKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'extendedPrivKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'extendedPrivKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'extendedPrivKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'extendedPrivKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extendedPrivKey',
        value: '',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      extendedPrivKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'extendedPrivKey',
        value: '',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> fingerPrintIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fingerPrint',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      fingerPrintIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fingerPrint',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> fingerPrintEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fingerPrint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      fingerPrintGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fingerPrint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> fingerPrintLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fingerPrint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> fingerPrintBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fingerPrint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> fingerPrintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fingerPrint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> fingerPrintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fingerPrint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> fingerPrintContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fingerPrint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> fingerPrintMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fingerPrint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> fingerPrintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fingerPrint',
        value: '',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      fingerPrintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fingerPrint',
        value: '',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> serialNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serialNumber',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      serialNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serialNumber',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> serialNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      serialNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> serialNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> serialNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serialNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      serialNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> serialNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> serialNumberContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serialNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> serialNumberMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serialNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      serialNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serialNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition>
      serialNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serialNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> startYearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startYear',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> startYearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startYear',
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> startYearEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startYear',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> startYearGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startYear',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> startYearLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startYear',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> startYearBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> typeEqualTo(
      WalletType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> typeGreaterThan(
    WalletType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> typeLessThan(
    WalletType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterFilterCondition> typeBetween(
    WalletType lower,
    WalletType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WalletDBQueryObject
    on QueryBuilder<WalletDB, WalletDB, QFilterCondition> {}

extension WalletDBQueryLinks
    on QueryBuilder<WalletDB, WalletDB, QFilterCondition> {}

extension WalletDBQuerySortBy on QueryBuilder<WalletDB, WalletDB, QSortBy> {
  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByEasyImport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easyImport', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByEasyImportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easyImport', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByExtendedPrivKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extendedPrivKey', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByExtendedPrivKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extendedPrivKey', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByFingerPrint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerPrint', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByFingerPrintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerPrint', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortBySerialNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortBySerialNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByStartYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByStartYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension WalletDBQuerySortThenBy
    on QueryBuilder<WalletDB, WalletDB, QSortThenBy> {
  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByEasyImport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easyImport', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByEasyImportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easyImport', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByExtendedPrivKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extendedPrivKey', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByExtendedPrivKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extendedPrivKey', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByFingerPrint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerPrint', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByFingerPrintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerPrint', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenBySerialNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenBySerialNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serialNumber', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByStartYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByStartYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.desc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension WalletDBQueryWhereDistinct
    on QueryBuilder<WalletDB, WalletDB, QDistinct> {
  QueryBuilder<WalletDB, WalletDB, QDistinct> distinctByEasyImport() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'easyImport');
    });
  }

  QueryBuilder<WalletDB, WalletDB, QDistinct> distinctByExtendedPrivKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extendedPrivKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QDistinct> distinctByFingerPrint(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fingerPrint', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QDistinct> distinctBySerialNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serialNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WalletDB, WalletDB, QDistinct> distinctByStartYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startYear');
    });
  }

  QueryBuilder<WalletDB, WalletDB, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension WalletDBQueryProperty
    on QueryBuilder<WalletDB, WalletDB, QQueryProperty> {
  QueryBuilder<WalletDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WalletDB, bool?, QQueryOperations> easyImportProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'easyImport');
    });
  }

  QueryBuilder<WalletDB, String?, QQueryOperations> extendedPrivKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extendedPrivKey');
    });
  }

  QueryBuilder<WalletDB, String?, QQueryOperations> fingerPrintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fingerPrint');
    });
  }

  QueryBuilder<WalletDB, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<WalletDB, String?, QQueryOperations> serialNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serialNumber');
    });
  }

  QueryBuilder<WalletDB, DateTime?, QQueryOperations> startYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startYear');
    });
  }

  QueryBuilder<WalletDB, WalletType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

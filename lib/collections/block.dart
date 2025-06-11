import 'package:isar/isar.dart';
import 'package:tejory/singleton.dart';

part 'block.g.dart';

@Collection()
class Block {
  Id id = Isar.autoIncrement;
  int? coin;

  @Index(unique: true, composite: [CompositeIndex('coin')])
  String? hash;

  @Index()
  int? height;
  DateTime? time;
  String? filePath;
  String? previousHash;

  Future<int> save() async {
    Isar isar = Singleton.getDB();

    int currentId = 0;

    await isar.writeTxn(() async {
      currentId = await isar.blocks.putByHashCoin(this);
    });
    return currentId;
  }

  int? getHeight({int depth = 0}) {
    if (height != null) {
      return height!;
    }
    if (depth > 25) {
      return null;
    }
    var isar = Singleton.getDB();
    var previousBlock =
        isar.blocks.where().hashCoinEqualTo(previousHash, coin).findFirstSync();

    if (previousBlock == null) {
      return null;
    }
    int? previousHeight = previousBlock.getHeight(depth: depth + 1);
    if (previousHeight == null) {
      return null;
    }
    return previousHeight + 1;
  }

  Future<int?> calculateHeight({int depth = 0}) async {
    if (height != null) {
      return height!;
    }
    if (depth > 25) {
      return null;
    }
    var isar = Singleton.getDB();
    var previousBlock =
        isar.blocks.where().hashCoinEqualTo(previousHash, coin).findFirstSync();

    if (previousBlock == null) {
      return null;
    }
    int? previousHeight = await previousBlock.calculateHeight(depth: depth + 1);
    if (previousHeight == null) {
      return null;
    }
    await isar.writeTxn(() async {
      await isar.blocks.putByHashCoin(this);
    });
    return previousHeight + 1;
  }
}

class BlockModel {
  const BlockModel();

  Future<Block?> getById(int id) async {
    Isar isar = Singleton.getDB();
    return isar.blocks.get(id);
  }

  Future<Block?> getUnique(String? hash, int? coin) async {
    Isar isar = Singleton.getDB();
    return isar.blocks.getByHashCoin(hash, coin);
  }

  Future<List<Block>?> find({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
    int? limit,
  }) async {
    Isar isar = Singleton.getDB();
    isar.blocks.filter().coinEqualTo(1).sortByCoinDesc().limit(1).findAll();
    Query<Block> query = isar.blocks.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc, limit: limit);
    try {
      return await query.findAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }

  Future<int?> count({
    FilterOperation? q,
    SortProperty? order,
    bool ascending = true,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<Block> query = isar.blocks.buildQuery(filter:q, sortBy:[if (order!= null) order], whereSort:ascending?Sort.asc:Sort.desc);
    try {
      return await query.count();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }

  Future<int?> delete({
    FilterOperation? q,
  }) async {
    Isar isar = Singleton.getDB();
    
    Query<Block> query = isar.blocks.buildQuery(filter:q);
    try {
      return await query.deleteAll();
    } catch (e) {
      print("ERROR: Balance.find ${e}");
      return null;
    }
  }
}
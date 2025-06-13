// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension BlockBoxModelHelpers on Block {
  Future<int?> save() async {
    return BlockModel().upsert(this);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class BlockModel extends BaseBoxModel<Block, isar.Block> {
  const BlockModel();

  Future<List<Block>?> find({
    Condition<Block>? q,
    QueryProperty<Block, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.blockBox.query(q);
    if (order != null) {
      queryBuilder = queryBuilder.order(
        order,
        flags: ascending ? 0 : Order.descending,
      );
    }
    final query = queryBuilder.build();
    if (limit != null) {
      query.limit = limit;
    }
    try {
      final result = query.find();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: Block.find ${e}");
      return null;
    }
  }

  Future<int?> delete({
    Condition<Block>? q,
  }) async {
    final objectbox = Singleton.getObjectBoxDB();
    var queryBuilder = objectbox.blockBox.query(q);
    final query = queryBuilder.build();
    try {
      final result = query.remove();
      query.close();
      return result;
    } catch (e) {
      print("ERROR: Block.delete ${e}");
      return null;
    }
  }

  Future<int?> count({Condition<Block>? q}) async {
    final objectbox = Singleton.getObjectBoxDB();
    final query = objectbox.blockBox.query(q).build();
    try {
      return query.count();
    } catch (e) {
      print("ERROR: Block.count ${e}");
      return null;
    } finally {
      query.close();
    }
  }

  Future<Block?> getById(int id) async {
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.blockBox.get(id);
  }

  Condition<Block> uniqueCondition(int? coin, String? hash) {
    return ((coin == null) ? Block_.coin.isNull() : Block_.coin.equals(coin)) &
        ((hash == null) ? Block_.hash.isNull() : Block_.hash.equals(hash));
  }

  Future<Block?> getUnique(int? coin, String? hash) async {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.blockBox.query(uniqueCondition(coin, hash)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Future<int> upsert(Block block) async {
    final box = Singleton.getObjectBoxDB();

    if (block.id != 0) {
      return box.blockBox.put(block);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query =
          box.blockBox.query(uniqueCondition(block.coin, block.hash)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        block.id = existingId[0];
      }

      return box.blockBox.put(block);
    });
  }

  Block fromIsar(isar.Block src) {
    Block val = Block();
    val.id = src.id;
    val.coin = src.coin;
    val.hash = src.hash;
    val.height = src.height;
    val.time = src.time;
    val.filePath = src.filePath;
    val.previousHash = src.previousHash;

    return val;
  }
}

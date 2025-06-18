// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// ExtentionGenerator
// **************************************************************************

extension BlockBoxModelHelpers on Block {
  int? save() {
    return BlockModel().upsert(this);
  }

  String getCPK() {
    return BlockModel().calculateCPK(coin, hash);
  }
}

// **************************************************************************
// StaticModelGenerator
// **************************************************************************

class BlockModel extends BaseBoxModel<Block, isar.Block> {
  const BlockModel();

  List<Block>? find({
    Condition<Block>? q,
    QueryProperty<Block, dynamic>? order,
    bool ascending = true,
    int? limit,
  }) {
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

  int? delete({
    Condition<Block>? q,
  }) {
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

  int? count({Condition<Block>? q}) {
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

  Block? getById(int id) {
    if (id == 0) {
      return null;
    }
    final objectbox = Singleton.getObjectBoxDB();
    return objectbox.blockBox.get(id);
  }

  Condition<Block> uniqueConditionMV(int? coin, String? hash) {
    return ((coin == null) ? Block_.coin.isNull() : Block_.coin.equals(coin)) &
        ((hash == null) ? Block_.hash.isNull() : Block_.hash.equals(hash));
  }

  Condition<Block> uniqueCondition(int? coin, String? hash) {
    return Block_.cpk.equals(calculateCPK(coin, hash));
  }

  String calculateCPK(int? coin, String? hash) {
    return CPK.calculateCPK([coin, hash]);
  }

  Block? getUniqueMV(int? coin, String? hash) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.blockBox.query(uniqueConditionMV(coin, hash)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Block? getUnique(int? coin, String? hash) {
    ObjectBox box = Singleton.getObjectBoxDB();
    final query = box.blockBox.query(uniqueCondition(coin, hash)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  int upsertMV(Block block) {
    final box = Singleton.getObjectBoxDB();

    if (block.id != 0) {
      return box.blockBox.put(block);
    }

    return box.getStore().runInTransaction(TxMode.write, () {
      final query =
          box.blockBox.query(uniqueConditionMV(block.coin, block.hash)).build();
      final existingId = query.findIds();
      query.close();

      if (existingId.isNotEmpty) {
        block.id = existingId[0];
      }

      return box.blockBox.put(block);
    });
  }

  int upsert(Block block) {
    final box = Singleton.getObjectBoxDB();
    block.cpk = block.getCPK();
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

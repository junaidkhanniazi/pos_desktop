import 'package:sqflite/sqflite.dart';
import 'package:pos_desktop/domain/entities/subscription_plan_entity.dart';

class SubscriptionPlanDao {
  final Database _database;

  SubscriptionPlanDao(this._database);

  Future<void> createTable() async {
    await _database.execute('''
      CREATE TABLE IF NOT EXISTS subscription_plans (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        duration_days INTEGER NOT NULL,
        features TEXT NOT NULL,
        maxStores INTEGER NOT NULL DEFAULT 0,
        maxProducts INTEGER NOT NULL DEFAULT 0,
        maxCategories INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> insertPlan(SubscriptionPlanEntity plan) async {
    try {
      print('🔄 === DEBUG: Inserting plan ===');
      print('Plan to insert: ${plan.toMap()}');

      final result = await _database.insert(
        'subscription_plans',
        plan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Plan inserted with ID: $result');
    } catch (e) {
      print('❌ Error inserting plan: $e');
      rethrow;
    }
  }

  Future<List<SubscriptionPlanEntity>> getAllActivePlans() async {
    try {
      print('🔄 === DEBUG: Fetching plans ===');

      final List<Map<String, dynamic>> maps = await _database.query(
        'subscription_plans',
        orderBy: 'price ASC',
      );

      print('📦 Found ${maps.length} plans in DB');
      for (final map in maps) {
        print('   Raw DB data: $map');
      }

      final entities = List.generate(maps.length, (i) {
        return SubscriptionPlanEntity.fromMap(maps[i]);
      });

      print('✅ Converted to ${entities.length} entities');
      return entities;
    } catch (e) {
      print('❌ Error in getAllActivePlans: $e');
      rethrow;
    }
  }

  Future<void> deletePlan(int planId) async {
    try {
      print('🗑️ === DEBUG: Deleting plan ID: $planId ===');

      final result = await _database.delete(
        'subscription_plans',
        where: 'id = ?',
        whereArgs: [planId],
      );

      print('✅ Deleted $planId, affected rows: $result');
    } catch (e) {
      print('❌ Error deleting plan: $e');
      rethrow;
    }
  }

  Future<SubscriptionPlanEntity?> getPlanById(int id) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'subscription_plans',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SubscriptionPlanEntity.fromMap(maps.first);
    }
    return null;
  }

  Future<void> debugPrintPlans() async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'subscription_plans',
    );
    print('=== DEBUG: Plans in database ===');
    print('Total plans found: ${maps.length}');
    for (final map in maps) {
      print('Plan: ${map['name']} - Price: ${map['price']}');
    }
    print('================================');
  }
}

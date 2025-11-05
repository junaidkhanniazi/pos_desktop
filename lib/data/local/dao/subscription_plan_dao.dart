import 'package:sqflite/sqflite.dart';
import 'package:pos_desktop/domain/entities/subscription_plan_entity.dart';
import 'package:pos_desktop/data/local/dao/subscription_dao.dart'; // ✅ added for helper

class SubscriptionPlanDao {
  final Database _database;

  SubscriptionPlanDao(this._database);

  // -------------------------------------------------
  // 🔹 Create Table
  // -------------------------------------------------
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

  // -------------------------------------------------
  // 🔹 Insert New Plan
  // -------------------------------------------------
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

  // -------------------------------------------------
  // 🔹 Get All Active Plans
  // -------------------------------------------------
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

  // -------------------------------------------------
  // 🔹 Delete Plan
  // -------------------------------------------------
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

  // -------------------------------------------------
  // 🔹 Get Plan By ID
  // -------------------------------------------------
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

  // -------------------------------------------------
  // 🔹 Debug Print (Utility)
  // -------------------------------------------------
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

  // -------------------------------------------------
  // 🔹 NEW: Get Plan Limits for Owner’s Latest Subscription
  // -------------------------------------------------
  Future<Map<String, dynamic>?> getOwnerPlanLimits(int ownerId) async {
    try {
      final subDao = SubscriptionDao();
      // ✅ Step 1: Get latest subscription
      final latest = await subDao.getLatestSubscription(ownerId);
      if (latest == null) {
        print('⚠️ No subscription found for owner_id=$ownerId');
        return null;
      }

      // ✅ Step 2: Ensure it’s active
      if (latest.status != 'active') {
        print('⚠️ Subscription is not active for owner_id=$ownerId');
        return null;
      }

      // ✅ Step 3: Get the plan details
      final planId = latest.subscriptionPlanId;
      if (planId == null) {
        print('❌ Subscription plan ID is null for owner_id=$ownerId');
        return null;
      }

      final plan = await getPlanById(planId);
      if (plan == null) {
        print('❌ No matching plan found for plan_id=$planId');
        return null;
      }

      // ✅ Step 4: Return only limits
      final limits = {
        'maxStores': plan.maxStores,
        'maxProducts': plan.maxProducts,
        'maxCategories': plan.maxCategories,
      };

      print('✅ Owner $ownerId plan limits: $limits');
      return limits;
    } catch (e) {
      print('❌ Error getting owner plan limits: $e');
      return null;
    }
  }
}

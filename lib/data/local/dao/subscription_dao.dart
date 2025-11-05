import 'package:logger/logger.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/subscription_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SubscriptionDao {
  final _dbHelper = DatabaseHelper();
  final _logger = Logger();

  // ======================================================
  // 🔹 Insert new subscription (ALWAYS insert, never overwrite)
  // ======================================================
  Future<int> insertSubscription(SubscriptionModel subscription) async {
    final db = await _dbHelper.database;
    try {
      final id = await _dbHelper.executeWithRetry(() async {
        return await db.insert(
          'subscriptions',
          subscription.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      });
      _logger.i('✅ Subscription inserted for ownerId: ${subscription.ownerId}');
      return id;
    } catch (e) {
      _logger.e('❌ Failed to insert subscription: $e');
      rethrow;
    }
  }

  // ======================================================
  // 🔹 Get all subscriptions
  // ======================================================
  Future<List<SubscriptionModel>> getAllSubscriptions() async {
    final db = await _dbHelper.database;
    try {
      final result = await db.query(
        'subscriptions',
        orderBy: 'created_at DESC',
      );
      return result.map((e) => SubscriptionModel.fromMap(e)).toList();
    } catch (e) {
      _logger.e('❌ Failed to fetch subscriptions: $e');
      return [];
    }
  }

  // ======================================================
  // 🔹 Get latest subscription (any status)
  // ======================================================
  Future<SubscriptionModel?> getSubscriptionByOwnerId(int ownerId) async {
    final db = await _dbHelper.database;
    try {
      final result = await db.query(
        'subscriptions',
        where: 'owner_id = ?',
        whereArgs: [ownerId],
        orderBy: 'id DESC',
        limit: 1,
      );
      if (result.isNotEmpty) {
        return SubscriptionModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      _logger.e('❌ Failed to get subscription for ownerId=$ownerId: $e');
      return null;
    }
  }

  // ======================================================
  // 🔹 Get all subscriptions for specific owner
  // ======================================================
  Future<List<SubscriptionModel>> getSubscriptionsByOwner(int ownerId) async {
    final db = await _dbHelper.database;
    try {
      final result = await db.query(
        'subscriptions',
        where: 'owner_id = ?',
        whereArgs: [ownerId],
        orderBy: 'id DESC',
      );
      return result.map((e) => SubscriptionModel.fromMap(e)).toList();
    } catch (e) {
      _logger.e('❌ Failed to fetch subscriptions for ownerId=$ownerId: $e');
      return [];
    }
  }

  // ======================================================
  // 🔹 Get the latest *valid active* subscription
  // ======================================================
  Future<SubscriptionModel?> getActiveSubscription(int ownerId) async {
    final db = await _dbHelper.database;
    try {
      final now = DateTime.now().toIso8601String();
      final result = await db.query(
        'subscriptions',
        where: '''
          owner_id = ? 
          AND status = 'active' 
          AND date(subscription_end_date) >= date(?)
        ''',
        whereArgs: [ownerId, now],
        orderBy: 'subscription_end_date DESC',
        limit: 1,
      );

      if (result.isNotEmpty) {
        return SubscriptionModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      _logger.e('❌ Failed to get active subscription: $e');
      return null;
    }
  }

  // ======================================================
  // 🔹 ✅ NEW: Get the latest subscription (ANY status)
  //     Used by SubscriptionPlanDao to find owner plan limits.
  // ======================================================
  Future<SubscriptionModel?> getLatestSubscription(int ownerId) async {
    final db = await _dbHelper.database;
    try {
      final result = await db.query(
        'subscriptions',
        where: 'owner_id = ?',
        whereArgs: [ownerId],
        orderBy: 'id DESC', // latest record by insert order
        limit: 1,
      );
      if (result.isNotEmpty) {
        final sub = SubscriptionModel.fromMap(result.first);
        _logger.i(
          '📦 Latest subscription for owner $ownerId → ${sub.subscriptionPlanName}',
        );
        return sub;
      }
      _logger.w('⚠️ No subscription found for owner $ownerId');
      return null;
    } catch (e) {
      _logger.e('❌ getLatestSubscription error: $e');
      return null;
    }
  }

  // ======================================================
  // 🔹 Mark expired subscriptions as inactive
  // ======================================================
  Future<void> markExpiredSubscriptions() async {
    final db = await _dbHelper.database;
    try {
      final now = DateTime.now().toIso8601String();
      final count = await db.rawUpdate(
        '''
        UPDATE subscriptions
        SET status = 'inactive', updated_at = ?
        WHERE date(subscription_end_date) < date(?)
          AND status = 'active'
      ''',
        [now, now],
      );
      _logger.i('⌛ Marked $count subscriptions as inactive (expired)');
    } catch (e) {
      _logger.e('❌ Failed to mark expired subscriptions: $e');
    }
  }

  // ======================================================
  // 🔹 Update subscription status manually
  // ======================================================
  Future<int> updateSubscriptionStatus(int id, String status) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'subscriptions',
        {'status': status, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.i('🔄 Updated subscription #$id to status=$status');
      return count;
    } catch (e) {
      _logger.e('❌ Failed to update subscription status: $e');
      rethrow;
    }
  }

  // ======================================================
  // 🔹 TEST: Force expire subscription
  // ======================================================
  Future<void> testExpireSubscription(int ownerId) async {
    final db = await _dbHelper.database;
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await db.update(
        'subscriptions',
        {
          'subscription_end_date': yesterday.toIso8601String(),
          'status': 'active',
        },
        where: 'owner_id = ?',
        whereArgs: [ownerId],
      );
      _logger.i('✅ TEST: Simulated expiry for owner $ownerId');
    } catch (e) {
      _logger.e('❌ TEST: Error expiring subscription: $e');
    }
  }

  // ======================================================
  // 🔹 Delete subscription by ID
  // ======================================================
  Future<int> deleteSubscription(int id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete(
        'subscriptions',
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.i('🗑️ Deleted subscription #$id');
      return count;
    } catch (e) {
      _logger.e('❌ Failed to delete subscription: $e');
      rethrow;
    }
  }

  // ======================================================
  // 🔹 Admin utility: clear all
  // ======================================================
  Future<void> clearAllSubscriptions() async {
    final db = await _dbHelper.database;
    try {
      await db.delete('subscriptions');
      _logger.w('⚠️ All subscriptions cleared!');
    } catch (e) {
      _logger.e('❌ Failed to clear subscriptions: $e');
    }
  }
}

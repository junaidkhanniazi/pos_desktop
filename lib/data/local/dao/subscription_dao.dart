import 'package:logger/logger.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/subscription_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SubscriptionDao {
  final _dbHelper = DatabaseHelper();
  final _logger = Logger();

  // ======================================================
  // 🔹 Insert new subscription
  // ======================================================
  Future<int> insertSubscription(SubscriptionModel subscription) async {
    final db = await _dbHelper.database;
    try {
      final id = await _dbHelper.executeWithRetry(() async {
        return await db.insert(
          'subscriptions',
          subscription.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
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
      final result = await db.query('subscriptions');
      return result.map((e) => SubscriptionModel.fromMap(e)).toList();
    } catch (e) {
      _logger.e('❌ Failed to fetch subscriptions: $e');
      return [];
    }
  }

  // 🔹 Get subscription by owner ID (any status)
  Future<SubscriptionModel?> getSubscriptionByOwnerId(int ownerId) async {
    final db = await _dbHelper.database;
    try {
      final result = await db.query(
        'subscriptions',
        where: 'owner_id = ?',
        whereArgs: [ownerId],
        orderBy: 'created_at DESC',
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
  // 🔹 Get subscriptions by owner ID
  // ======================================================
  Future<List<SubscriptionModel>> getSubscriptionsByOwner(int ownerId) async {
    final db = await _dbHelper.database;
    try {
      final result = await db.query(
        'subscriptions',
        where: 'owner_id = ?',
        whereArgs: [ownerId],
      );
      return result.map((e) => SubscriptionModel.fromMap(e)).toList();
    } catch (e) {
      _logger.e('❌ Failed to fetch subscriptions for ownerId=$ownerId: $e');
      return [];
    }
  }

  // ======================================================
  // 🔹 Get active subscription for an owner
  // ======================================================
  Future<SubscriptionModel?> getActiveSubscription(int ownerId) async {
    final db = await DatabaseHelper().database;

    // ✅ Fetch latest subscription for that owner, regardless of status
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
  }

  // In subscription_dao.dart - Add this test method
  Future<void> testExpireSubscription(int ownerId) async {
    final db = await _dbHelper.database;
    try {
      // Set subscription end date to yesterday (expired)
      final yesterday = DateTime.now().subtract(Duration(days: 1));

      await db.update(
        'subscriptions',
        {
          'subscription_end_date': yesterday.toIso8601String(),
          'status': 'active', // Keep status as active to test auto-logout
        },
        where: 'owner_id = ?',
        whereArgs: [ownerId],
      );

      _logger.i('✅ TEST: Made subscription expired for owner $ownerId');
    } catch (e) {
      _logger.e('❌ TEST: Error expiring subscription: $e');
    }
  }

  // ======================================================
  // 🔹 Update subscription status
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
  // 🔹 Mark expired subscriptions
  // ======================================================
  Future<void> markExpiredSubscriptions() async {
    final db = await _dbHelper.database;
    try {
      final now = DateTime.now().toIso8601String();
      final count = await db.rawUpdate(
        '''
        UPDATE subscriptions
        SET status = 'expired', updated_at = ?
        WHERE date(subscription_end_date) < date(?)
          AND status != 'expired'
      ''',
        [now, now],
      );
      _logger.i('⌛ Marked $count subscriptions as expired');
    } catch (e) {
      _logger.e('❌ Failed to mark expired subscriptions: $e');
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
  // 🔹 Clear all subscriptions (admin tool)
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

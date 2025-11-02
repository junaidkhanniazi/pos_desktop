import 'dart:math';
import 'package:logger/logger.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/core/errors/failure.dart';
import 'package:pos_desktop/data/local/dao/store_dao.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/owner_model.dart';

class OwnerDao {
  final _dbHelper = DatabaseHelper();
  final _logger = Logger();
  final _storeDao = StoreDao();

  // 🔹 Insert new owner (Signup request)
  Future<int> insertOwner(OwnerModel owner) async {
    try {
      final db = await _dbHelper.database;
      return await _dbHelper.executeWithRetry(() async {
        final existing = await db.query(
          'owners',
          where: 'email = ?',
          whereArgs: [owner.email],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          throw ValidationFailure('An owner with this email already exists');
        }
        final id = await db.insert('owners', owner.toMap());
        _logger.i('🧾 New owner registered (pending approval) → ID: $id');
        return id;
      });
    } catch (e) {
      _logger.e('❌ insertOwner error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Fetch all pending requests
  Future<List<OwnerModel>> getPendingOwners() async {
    try {
      final db = await _dbHelper.database;
      print("📍 DB Path (OwnerDao): ${(await _dbHelper.database).path}");

      return await _dbHelper.executeWithRetry(() async {
        final result = await db.query(
          'owners',
          where: 'status = ?',
          whereArgs: ['pending'],
          orderBy: 'id DESC',
        );
        return result.map((e) => OwnerModel.fromMap(e)).toList();
      });
    } catch (e) {
      _logger.e('❌ getPendingOwners error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Activate owner (approve + generate code)
  Future<void> activateOwner(
    int ownerId,
    int superAdminId,
    int durationDays,
  ) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final endDate = now.add(Duration(days: durationDays));

      await _dbHelper.executeWithRetry(() async {
        // 1. Pehle owner ko activate karen
        final count = await db.update(
          'owners',
          {
            'status': 'approved',
            'is_active': 1,
            'super_admin_id': superAdminId,
            'subscription_start_date': now.toIso8601String(),
            'subscription_end_date': endDate.toIso8601String(),
            'activation_code': _generateActivationCode(),
          },
          where: 'id = ?',
          whereArgs: [ownerId],
        );

        if (count == 0) {
          throw DatabaseFailure('Owner not found with id=$ownerId');
        }

        _logger.i(
          '✅ Owner activated (id=$ownerId) - Subscription: $now to $endDate (${durationDays} days)',
        );

        // ✅ NEW: AUTOMATICALLY CREATE MASTER DB & DEFAULT STORE
        final owner = await getOwnerById(ownerId);
        if (owner != null) {
          try {
            // Owner name derive karen (email se agar ownerName field nahi hai)
            final ownerName = _getOwnerName(owner);

            // Master DB create karen
            await _dbHelper.openMasterDB(ownerId, ownerName);
            _logger.i('✅ Master DB created for $ownerName');

            // Default store create karen
            await _dbHelper.openStoreDB(ownerId, ownerName, 1, 'Main Store');
            _logger.i('✅ Default store created for $ownerName');

            _logger.i('🎉 Automatic store setup completed for $ownerName');
          } catch (storeError) {
            _logger.e(
              '⚠️ Store creation failed but owner activated: $storeError',
            );
            // Store creation fail hone par bhi owner activated rahega
          }
        }
      });
    } catch (e) {
      _logger.e('❌ activateOwner error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  String _getOwnerName(OwnerModel owner) {
    // Pehle owner_name field check karen, agar nahi hai to email se derive karen
    if (owner.ownerName != null && owner.ownerName!.isNotEmpty) {
      return owner.ownerName!;
    }

    // Agar owner_name nahi hai to email se name derive karen
    final emailParts = owner.email.split('@');
    return emailParts.first; // junaid@gmail.com -> junaid
  }

  // 🔹 Reject owner
  Future<int> rejectOwner(int ownerId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        'owners',
        {'status': 'rejected', 'is_active': 0},
        where: 'id = ?',
        whereArgs: [ownerId],
      );
      if (count == 0) throw DatabaseFailure('Owner not found');
      _logger.i('🚫 Owner rejected (id=$ownerId)');
      return count;
    } catch (e) {
      _logger.e('❌ rejectOwner error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Delete owner
  Future<int> deleteOwner(int ownerId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'owners',
        where: 'id = ?',
        whereArgs: [ownerId],
      );
      if (count == 0) throw DatabaseFailure('Owner not found');
      _logger.i('🗑️ Owner deleted (id=$ownerId)');
      return count;
    } catch (e) {
      _logger.e('❌ deleteOwner error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Owner login verification
  Future<OwnerModel?> getOwnerByCredentials(
    String email,
    String password, {
    String? activationCode,
  }) async {
    try {
      final db = await _dbHelper.database;
      final where = activationCode != null
          ? 'email = ? AND password = ? AND activation_code = ? AND status = ? AND is_active = 1'
          : 'email = ? AND password = ? AND status = ? AND is_active = 1';
      final args = activationCode != null
          ? [email, password, activationCode, 'approved']
          : [email, password, 'approved'];

      final result = await db.query(
        'owners',
        where: where,
        whereArgs: args,
        limit: 1,
      );

      if (result.isEmpty) return null;

      final owner = OwnerModel.fromMap(result.first);

      // ✅ CHECK SUBSCRIPTION EXPIRY
      if (owner.isSubscriptionExpired) {
        throw Exception('Your subscription has expired. Please renew.');
      }

      // ✅ CHECK IF SUBSCRIPTION IS EXPIRING SOON (7 days or less)
      if (owner.isSubscriptionExpiringSoon) {
        final daysLeft = DateTime.parse(
          owner.subscriptionEndDate!,
        ).difference(DateTime.now()).inDays;
        _logger.w(
          '⚠️ Subscription expiring soon for ${owner.email} - ${daysLeft} days left',
        );
      }

      _logger.i('✅ Owner login successful: ${owner.email}');
      return owner;
    } catch (e) {
      _logger.e('❌ getOwnerByCredentials error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // ✅ NEW: Get owner by email only (for subscription checks)
  Future<OwnerModel?> getOwnerByEmail(String email) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'owners',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (result.isEmpty) return null;

      final owner = OwnerModel.fromMap(result.first);
      _logger.i('✅ Found owner by email: ${owner.email}');
      return owner;
    } catch (e) {
      _logger.e('❌ getOwnerByEmail error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // ✅ NEW: Get owner by ID
  Future<OwnerModel?> getOwnerById(int ownerId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'owners',
        where: 'id = ?',
        whereArgs: [ownerId],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return OwnerModel.fromMap(result.first);
    } catch (e) {
      _logger.e('❌ getOwnerById error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // ✅ NEW: Update owner subscription end date
  Future<void> updateSubscriptionEndDate(
    int ownerId,
    DateTime newEndDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        'owners',
        {
          'subscription_end_date': newEndDate.toIso8601String(),
          'is_active': 1, // Reactivate if was deactivated
        },
        where: 'id = ?',
        whereArgs: [ownerId],
      );

      if (count == 0) {
        throw DatabaseFailure('Owner not found with id=$ownerId');
      }

      _logger.i(
        '✅ Updated subscription end date for owner $ownerId to $newEndDate',
      );
    } catch (e) {
      _logger.e('❌ updateSubscriptionEndDate error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Get all owners
  Future<List<OwnerModel>> getAllOwners() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query('owners', orderBy: 'id DESC');
      return result.map((e) => OwnerModel.fromMap(e)).toList();
    } catch (e) {
      _logger.e('❌ getAllOwners error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Get approved owners
  Future<List<OwnerModel>> getApprovedOwners() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'owners',
        where: 'status = ?',
        whereArgs: ['approved'],
        orderBy: 'id DESC',
      );
      return result.map((e) => OwnerModel.fromMap(e)).toList();
    } catch (e) {
      _logger.e('❌ getApprovedOwners error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Get owners with uploaded receipts
  Future<List<OwnerModel>> getOwnersWithReceipt() async {
    try {
      final db = await _dbHelper.database;
      return await _dbHelper.executeWithRetry(() async {
        final result = await db.query(
          'owners',
          where: 'receipt_image IS NOT NULL AND receipt_image != ?',
          whereArgs: [''],
          orderBy: 'id DESC',
        );
        _logger.i('📸 Found ${result.length} owners with receipts');
        return result.map((e) => OwnerModel.fromMap(e)).toList();
      });
    } catch (e) {
      _logger.e('❌ getOwnersWithReceipt error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Get all active subscription plans
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final db = await _dbHelper.database;
      return await _dbHelper.executeWithRetry(() async {
        final result = await db.query(
          'subscription_plans',
          orderBy: 'price ASC',
        );
        _logger.i('📦 Loaded ${result.length} subscription plans');

        // 🔹 DEBUG PRINT
        print("=== DEBUG: Subscription Plans from Database ===");
        for (final plan in result) {
          print(
            "Plan: ${plan['name']} | Duration: ${plan['duration_days']} days | Price: ${plan['price']}",
          );
        }
        print("==============================================");

        return result;
      });
    } catch (e) {
      _logger.e('❌ getSubscriptionPlans error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Update subscription details
  Future<int> updateOwnerSubscription({
    required int ownerId,
    required String subscriptionPlan,
    required String receiptImage,
    required double subscriptionAmount,
    required int durationDays,
  }) async {
    try {
      final db = await _dbHelper.database;
      final endDate = DateTime.now().add(Duration(days: durationDays));
      final count = await db.update(
        'owners',
        {
          'subscription_plan': subscriptionPlan,
          'receipt_image': receiptImage,
          'payment_date': DateTime.now().toIso8601String(),
          'subscription_amount': subscriptionAmount,
          'subscription_end_date': endDate.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [ownerId],
      );
      if (count == 0) throw DatabaseFailure('Owner not found');
      _logger.i('💰 Updated subscription for owner=$ownerId (ends: $endDate)');
      return count;
    } catch (e) {
      _logger.e('❌ updateOwnerSubscription error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Get owners with expired subscriptions
  Future<List<OwnerModel>> getOwnersWithExpiredSubscriptions() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now().toIso8601String();

      return await _dbHelper.executeWithRetry(() async {
        final result = await db.query(
          'owners',
          where:
              'subscription_end_date IS NOT NULL AND subscription_end_date < ? AND status = ? AND is_active = ?',
          whereArgs: [now, 'approved', 1],
          orderBy: 'subscription_end_date ASC',
        );
        _logger.i('🕒 Found ${result.length} expired subscriptions');
        return result.map((e) => OwnerModel.fromMap(e)).toList();
      });
    } catch (e) {
      _logger.e('❌ getOwnersWithExpiredSubscriptions error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Deactivate expired subscriptions
  Future<int> deactivateExpiredSubscriptions() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now().toIso8601String();
      return await _dbHelper.executeWithRetry(() async {
        final count = await db.update(
          'owners',
          {'status': 'suspended', 'is_active': 0},
          where:
              'subscription_end_date IS NOT NULL AND subscription_end_date < ? AND status = ? AND is_active = ?',
          whereArgs: [now, 'approved', 1],
        );
        _logger.i('🔴 Deactivated $count expired subscriptions');
        return count;
      });
    } catch (e) {
      _logger.e('❌ deactivateExpiredSubscriptions error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Get owners with subscriptions expiring soon (7 days)
  Future<List<OwnerModel>> getOwnersWithExpiringSubscriptions() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final weekLater = now.add(const Duration(days: 7));

      return await _dbHelper.executeWithRetry(() async {
        final result = await db.query(
          'owners',
          where:
              'subscription_end_date IS NOT NULL AND subscription_end_date BETWEEN ? AND ? AND status = ? AND is_active = ?',
          whereArgs: [
            now.toIso8601String(),
            weekLater.toIso8601String(),
            'approved',
            1,
          ],
          orderBy: 'subscription_end_date ASC',
        );
        _logger.i('📅 Found ${result.length} expiring soon (≤7 days)');
        return result.map((map) => OwnerModel.fromMap(map)).toList();
      });
    } catch (e) {
      _logger.e('❌ getOwnersWithExpiringSubscriptions error: $e');
      throw ExceptionHandler.handle(e);
    }
  }

  // 🔹 Generate activation code
  String _generateActivationCode() {
    final rng = Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  // 🔹 TEST METHODS

  // TEMPORARY: For testing expired subscription
  Future<void> createTestExpiredOwner() async {
    try {
      final db = await _dbHelper.database;
      final expiredOwner = {
        'name': 'Test Expired Owner',
        'email': 'expired@test.com',
        'password': 'password',
        'contact': '1234567890',
        'status': 'approved',
        'is_active': 1,
        'activation_code': '999999',
        'created_at': DateTime.now().toIso8601String(),
        'subscription_plan_id': 1761893834219, // basic plan ID
        'subscription_start_date': DateTime(2024, 10, 1).toIso8601String(),
        'subscription_end_date': DateTime.now()
            .subtract(Duration(days: 1))
            .toIso8601String(),
      };

      await db.insert('owners', expiredOwner);
      print('✅ Test expired owner created: expired@test.com');
    } catch (e) {
      print('❌ Error creating test expired owner: $e');
    }
  }

  Future<void> expireOwnerNow(int ownerId) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'owners',
        {
          'subscription_end_date': DateTime.now()
              .subtract(Duration(days: 1))
              .toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [ownerId],
      );
      print('✅ Made owner $ownerId subscription expired');
    } catch (e) {
      print('❌ Error expiring owner: $e');
    }
  }

  // ✅ NEW: Renew subscription
  Future<void> renewSubscription({
    required int ownerId,
    required int durationDays,
    required double amount,
    required String planName,
  }) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final endDate = now.add(Duration(days: durationDays));

      final count = await db.update(
        'owners',
        {
          'subscription_plan': planName,
          'subscription_amount': amount,
          'payment_date': now.toIso8601String(),
          'subscription_start_date': now.toIso8601String(),
          'subscription_end_date': endDate.toIso8601String(),
          'status': 'approved',
          'is_active': 1,
        },
        where: 'id = ?',
        whereArgs: [ownerId],
      );

      if (count == 0) {
        throw DatabaseFailure('Owner not found with id=$ownerId');
      }

      _logger.i('🔄 Subscription renewed for owner $ownerId until $endDate');
    } catch (e) {
      _logger.e('❌ renewSubscription error: $e');
      throw ExceptionHandler.handle(e);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:pos_desktop/data/local/dao/subscription_dao.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/owner_model.dart';
import 'package:pos_desktop/domain/entities/owner_entity.dart';
import 'package:pos_desktop/domain/entities/subscription_entity.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';

class OwnerRepositoryImpl implements OwnerRepository {
  static final OwnerRepositoryImpl _instance = OwnerRepositoryImpl._internal();
  factory OwnerRepositoryImpl() => _instance;
  OwnerRepositoryImpl._internal();

  final OwnerDao _ownerDao = OwnerDao();

  @override
  Future<void> addOwner(OwnerEntity owner) async {
    final model = OwnerModel(
      shopName: owner.storeName,
      ownerName: owner.name,
      email: owner.email,
      password: owner.password,
      contact: owner.contact,
      superAdminId: owner.superAdminId != null
          ? int.tryParse(owner.superAdminId!)
          : null,
      status: owner.status.name,
      isActive: owner.status == OwnerStatus.active,
      createdAt: owner.createdAt.toIso8601String(),
    );
    await _ownerDao.insertOwner(model);
  }

  @override
  Future<void> activateOwner(
    String ownerId,
    String superAdminId,
    int durationDays,
    BuildContext context,
  ) async {
    await _ownerDao.activateOwner(
      int.parse(ownerId),
      int.parse(superAdminId),
      durationDays,
      context,
    );

    try {
      final db = await DatabaseHelper().database;
      await db.update(
        'subscriptions',
        {'status': 'active'},
        where: 'owner_id = ?',
        whereArgs: [int.parse(ownerId)],
      );
      debugPrint("✅ Subscription activated for owner_id=$ownerId");
    } catch (e) {
      debugPrint("❌ Failed to activate subscription for owner_id=$ownerId: $e");
    }
  }

  @override
  Future<void> rejectOwner(String ownerId) async {
    await _ownerDao.rejectOwner(int.parse(ownerId));
  }

  @override
  Future<void> deleteOwner(String ownerId) async {
    await _ownerDao.deleteOwner(int.parse(ownerId));
  }

  @override
  Future<List<OwnerEntity>> getAllOwners() async {
    final models = await _ownerDao.getAllOwners();
    return models.map((m) => m.toEntity()).toList();
  }

  // ✅ OLD METHOD (kept for reuse elsewhere)
  @override
  Future<List<OwnerEntity>> getPendingOwners() async {
    final models = await _ownerDao.getPendingOwners();
    return models.map((m) => m.toEntity()).toList();
  }

  // ✅ NEW METHOD — use this for admin (includes plan + receipt)
  Future<List<Map<String, dynamic>>> getPendingOwnersWithSubscriptions() async {
    try {
      final result = await _ownerDao.getPendingOwnersWithSubscriptions();
      return result;
    } catch (e) {
      throw Exception("Error fetching pending owners with subscriptions: $e");
    }
  }

  @override
  Future<List<OwnerEntity>> getApprovedOwners() async {
    final models = await _ownerDao.getApprovedOwners();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<OwnerEntity?> getOwnerByCredentials(
    String email,
    String password, {
    String? activationCode,
  }) async {
    final model = await _ownerDao.getOwnerByCredentials(email, password);
    return model?.toEntity();
  }

  @override
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    return await _ownerDao.getSubscriptionPlans();
  }

  @override
  Future<void> updateOwnerSubscription({
    required String ownerId,
    required String subscriptionPlan,
    required String receiptImage,
    required double subscriptionAmount,
  }) async {
    final plans = await _ownerDao.getSubscriptionPlans();
    final plan = plans.firstWhere(
      (p) => p['name'] == subscriptionPlan,
      orElse: () => {'duration_days': 30},
    );
    final durationDays = plan['duration_days'] ?? 30;
    await _ownerDao.updateOwnerSubscription(
      ownerId: int.parse(ownerId),
      subscriptionPlan: subscriptionPlan,
      receiptImage: receiptImage,
      subscriptionAmount: subscriptionAmount,
      durationDays: durationDays,
    );
  }

  @override
  Future<List<OwnerEntity>> getOwnersWithReceipt() async {
    final models = await _ownerDao.getOwnersWithReceipt();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<OwnerEntity>> getExpiringSubscriptions() async {
    final models = await _ownerDao.getOwnersWithExpiringSubscriptions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<OwnerEntity>> getExpiredSubscriptions() async {
    final models = await _ownerDao.getOwnersWithExpiredSubscriptions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<SubscriptionEntity?> getOwnerSubscription(String ownerId) async {
    // 🟢 Use latest subscription (any status)
    final subscriptionDao = SubscriptionDao();
    final model = await subscriptionDao.getSubscriptionByOwnerId(
      int.parse(ownerId),
    );
    return model?.toEntity();
  }
}

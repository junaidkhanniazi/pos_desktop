// domain/repositories/repositories_impl/owner_repository_impl.dart
import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:pos_desktop/data/models/owner_model.dart';
import 'package:pos_desktop/domain/entities/owner_entity.dart';
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
      password: owner.password, // ✅ FIXED: Use actual password from entity
      contact: owner.contact, // ✅ ADDED: Missing field
      superAdminId: owner.superAdminId != null
          ? int.tryParse(owner.superAdminId!)
          : null, // ✅ ADDED: convert nullable String to int?
      status: owner.status.name,
      isActive: owner.status == OwnerStatus.active,
      createdAt: owner.createdAt.toIso8601String(),
      activationCode: owner.activationCode, // ✅ ADDED: Missing field
      subscriptionPlan: owner.subscriptionPlan,
      receiptImage: owner.receiptImage,
      paymentDate: owner.paymentDate?.toIso8601String(),
      subscriptionAmount: owner.subscriptionAmount,
      subscriptionStartDate: owner.subscriptionStartDate
          ?.toIso8601String(), // ✅ ADDED: Missing field
      subscriptionEndDate: owner.subscriptionEndDate?.toIso8601String(),
    );
    await _ownerDao.insertOwner(model);
  }

  @override
  // ✅ NEW - With all required parameters
  Future<void> activateOwner(
    String ownerId,
    String superAdminId,
    int durationDays,
  ) async {
    await _ownerDao.activateOwner(
      int.parse(ownerId),
      int.parse(superAdminId),
      durationDays,
    );
  }

  @override
  Future<void> rejectOwner(String ownerId) async {
    try {
      await _ownerDao.rejectOwner(int.parse(ownerId));
    } catch (e) {
      throw Exception("Error rejecting owner: $e");
    }
  }

  @override
  Future<void> deleteOwner(String ownerId) async {
    try {
      await _ownerDao.deleteOwner(int.parse(ownerId));
    } catch (e) {
      throw Exception("Error deleting owner: $e");
    }
  }

  @override
  Future<List<OwnerEntity>> getAllOwners() async {
    try {
      final models = await _ownerDao.getAllOwners();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception("Error fetching all owners: $e");
    }
  }

  @override
  Future<List<OwnerEntity>> getPendingOwners() async {
    try {
      final models = await _ownerDao.getPendingOwners();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception("Error fetching pending owners: $e");
    }
  }

  @override
  Future<List<OwnerEntity>> getApprovedOwners() async {
    try {
      final models = await _ownerDao.getApprovedOwners();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception("Error fetching approved owners: $e");
    }
  }

  @override
  Future<OwnerEntity?> getOwnerByCredentials(
    String email,
    String password, {
    String? activationCode,
  }) async {
    try {
      final model = await _ownerDao.getOwnerByCredentials(
        email,
        password,
        activationCode: activationCode,
      );
      return model?.toEntity();
    } catch (e) {
      throw Exception("Error fetching owner by credentials: $e");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      return await _ownerDao.getSubscriptionPlans();
    } catch (e) {
      throw Exception("Error fetching subscription plans: $e");
    }
  }

  @override
  Future<void> updateOwnerSubscription({
    required String ownerId,
    required String subscriptionPlan,
    required String receiptImage,
    required double subscriptionAmount,
  }) async {
    try {
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
    } catch (e) {
      throw Exception("Error updating owner subscription: $e");
    }
  }

  @override
  Future<List<OwnerEntity>> getOwnersWithReceipt() async {
    try {
      final models = await _ownerDao.getOwnersWithReceipt();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception("Error fetching owners with receipt: $e");
    }
  }

  @override
  Future<List<OwnerEntity>> getExpiringSubscriptions() async {
    try {
      final models = await _ownerDao.getOwnersWithExpiringSubscriptions();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception("Error fetching expiring subscriptions: $e");
    }
  }

  @override
  Future<List<OwnerEntity>> getExpiredSubscriptions() async {
    try {
      final models = await _ownerDao.getOwnersWithExpiredSubscriptions();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception("Error fetching expired subscriptions: $e");
    }
  }
}

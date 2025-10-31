import 'package:pos_desktop/domain/entities/owner_entity.dart';

abstract class OwnerRepository {
  Future<List<OwnerEntity>> getAllOwners();
  Future<List<OwnerEntity>> getPendingOwners();
  Future<List<OwnerEntity>> getApprovedOwners();
  Future<void> addOwner(OwnerEntity owner);
  Future<void> activateOwner(String ownerId);
  Future<void> rejectOwner(String ownerId);
  Future<void> deleteOwner(String ownerId);
  Future<OwnerEntity?> getOwnerByCredentials(
    String email,
    String password, {
    String? activationCode,
  });

  // Subscription-related
  Future<List<Map<String, dynamic>>> getSubscriptionPlans();
  Future<void> updateOwnerSubscription({
    required String ownerId,
    required String subscriptionPlan,
    required String receiptImage,
    required double subscriptionAmount,
  });
  Future<List<OwnerEntity>> getOwnersWithReceipt();
  Future<List<OwnerEntity>> getExpiringSubscriptions();
  Future<List<OwnerEntity>> getExpiredSubscriptions();
}

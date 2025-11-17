import 'package:pos_desktop/domain/entities/online/owner_entity.dart';

abstract class OwnerRepository {
  // 🔹 Basic CRUD for owners
  Future<List<OwnerEntity>> getAllOwners();
  Future<List<OwnerEntity>> getPendingOwners();
  Future<List<OwnerEntity>> getApprovedOwners();
  Future<void> addOwner(OwnerEntity owner);
  Future<void> deleteOwner(String ownerId);

  // 🔹 Owner account activation / rejection
  Future<void> activateOwner(String ownerId, int durationDays);
  Future<void> rejectOwner(int ownerId);

  // 🔹 Authentication
  Future<OwnerEntity?> getOwnerByCredentials(
    String email,
    String password, {
    String? activationCode,
  });

  // 🔹 Admin views (owners filtered by subscription state)
  Future<List<OwnerEntity>> getOwnersWithReceipt();
  Future<List<OwnerEntity>> getExpiringSubscriptions();
  Future<List<OwnerEntity>> getExpiredSubscriptions();

  // ✅ Optional: Return extra info in admin view
  Future<List<Map<String, dynamic>>> getPendingOwnersWithSubscriptions();
}

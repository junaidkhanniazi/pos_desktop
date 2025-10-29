import 'package:pos_desktop/domain/entities/owner_entity.dart';

/// Defines abstract contract between domain and data layer.
/// Domain layer (usecases) depends only on this interface —
/// not on any database or API implementation.
abstract class OwnerRepository {
  /// Fetch all owners (for Super Admin dashboard)
  Future<List<OwnerEntity>> getAllOwners();

  /// Fetch pending owner requests
  Future<List<OwnerEntity>> getPendingOwners();

  /// Fetch approved & active owners
  Future<List<OwnerEntity>> getApprovedOwners();

  /// Add a new owner (signup request)
  Future<void> addOwner(OwnerEntity owner);

  /// Activate owner (approve + generate activation code)
  Future<void> activateOwner(String ownerId);

  /// Reject pending owner
  Future<void> rejectOwner(String ownerId);

  /// Delete owner completely (if needed)
  Future<void> deleteOwner(String ownerId);

  /// Get owner by email + password (+ optional activation code)
  Future<OwnerEntity?> getOwnerByCredentials(
    String email,
    String password, {
    String? activationCode,
  });
}

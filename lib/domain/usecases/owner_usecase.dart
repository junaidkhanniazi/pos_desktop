import 'package:pos_desktop/domain/entities/online/owner_entity.dart';
import 'package:pos_desktop/domain/entities/online/subscription_entity.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';

class OwnerUseCase {
  final OwnerRepository _repository;
  OwnerUseCase(this._repository);

  Future<void> addOwner(OwnerEntity owner) => _repository.addOwner(owner);
  Future<void> activateOwner(String ownerId, int durationDays) =>
      _repository.activateOwner(ownerId, durationDays);
  Future<void> rejectOwner(int ownerId) => _repository.rejectOwner(ownerId);

  Future<List<OwnerEntity>> getAll() => _repository.getAllOwners();
  Future<List<OwnerEntity>> getPending() => _repository.getPendingOwners();
  Future<SubscriptionEntity?> getSubscription(String ownerId) =>
      _repository.getOwnerSubscription(ownerId);
}

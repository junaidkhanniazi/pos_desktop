import 'package:pos_desktop/domain/repositories/owner_repository.dart';

class ActivateOwnerUseCase {
  final OwnerRepository _repository;

  ActivateOwnerUseCase(this._repository);

  // ✅ UPDATED - 3 parameters
  Future<void> call(
    String ownerId,
    String superAdminId,
    int durationDays,
  ) async {
    await _repository.activateOwner(ownerId, superAdminId, durationDays);
  }
}

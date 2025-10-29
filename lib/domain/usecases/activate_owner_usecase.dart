import 'package:pos_desktop/domain/repositories/owner_repository.dart';

class ActivateOwnerUseCase {
  final OwnerRepository _repository;

  ActivateOwnerUseCase(this._repository);

  Future<void> call(String ownerId) async {
    await _repository.activateOwner(ownerId);
  }
}

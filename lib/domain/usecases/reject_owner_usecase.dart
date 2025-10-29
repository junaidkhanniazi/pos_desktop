import 'package:pos_desktop/domain/repositories/owner_repository.dart';

class RejectOwnerUseCase {
  final OwnerRepository _repository;

  RejectOwnerUseCase(this._repository);

  Future<void> call(String ownerId) async {
    await _repository.rejectOwner(ownerId);
  }
}

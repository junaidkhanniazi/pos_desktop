import 'package:pos_desktop/domain/entities/owner_entity.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';

class AddOwnerUseCase {
  final OwnerRepository _repository;

  AddOwnerUseCase(this._repository);

  Future<void> call(OwnerEntity owner) async {
    await _repository.addOwner(owner);
  }
}

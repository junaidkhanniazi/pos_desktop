import 'package:pos_desktop/domain/entities/owner_entity.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';

class GetAllOwnersUseCase {
  final OwnerRepository _repository;

  GetAllOwnersUseCase(this._repository);

  Future<List<OwnerEntity>> call() async {
    return await _repository.getAllOwners();
  }
}

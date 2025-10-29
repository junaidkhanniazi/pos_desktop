import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:pos_desktop/data/models/owner_model.dart';
import 'package:pos_desktop/domain/entities/owner_entity.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';

/// Concrete implementation of [OwnerRepository]
/// Uses SQLite through [OwnerDao]
class OwnerRepositoryImpl implements OwnerRepository {
  final OwnerDao _ownerDao;

  OwnerRepositoryImpl(this._ownerDao);

  @override
  Future<void> addOwner(OwnerEntity owner) async {
    final model = OwnerModel(
      shopName: owner.storeName,
      ownerName: owner.name,
      email: owner.email,
      password: '', // password handled in presentation layer
      status: owner.status.name,
      isActive: owner.status == OwnerStatus.active,
      createdAt: owner.createdAt.toIso8601String(),
    );
    await _ownerDao.insertOwner(model);
  }

  @override
  Future<void> activateOwner(String ownerId) async {
    await _ownerDao.activateOwner(int.parse(ownerId));
  }

  @override
  Future<void> rejectOwner(String ownerId) async {
    await _ownerDao.rejectOwner(int.parse(ownerId));
  }

  @override
  Future<void> deleteOwner(String ownerId) async {
    await _ownerDao.deleteOwner(int.parse(ownerId));
  }

  @override
  Future<List<OwnerEntity>> getAllOwners() async {
    final models = await _ownerDao.getAllOwners();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<OwnerEntity>> getPendingOwners() async {
    final models = await _ownerDao.getPendingOwners();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<OwnerEntity>> getApprovedOwners() async {
    final models = await _ownerDao.getApprovedOwners();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<OwnerEntity?> getOwnerByCredentials(
    String email,
    String password, {
    String? activationCode,
  }) async {
    final model = await _ownerDao.getOwnerByCredentials(
      email,
      password,
      activationCode: activationCode,
    );
    return model?.toEntity();
  }
}

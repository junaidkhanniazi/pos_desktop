import 'package:pos_desktop/data/models/owner_model.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';
import 'package:pos_desktop/domain/entities/online/owner_entity.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';

class OwnerRepositoryImpl implements OwnerRepository {
  // 🔹 Helpers to map List<dynamic> → List<OwnerEntity>
  List<OwnerEntity> _mapOwners(List<dynamic> data) {
    return data
        .whereType<Map<String, dynamic>>()
        .map((map) => OwnerModel.fromMap(map))
        .cast<OwnerEntity>()
        .toList();
  }

  @override
  Future<List<OwnerEntity>> getAllOwners() async {
    final data = await SyncApi.get("owners");
    return _mapOwners(data);
  }

  @override
  Future<List<OwnerEntity>> getPendingOwners() async {
    final data = await SyncApi.get("owners/pending-with-subscriptions");
    return _mapOwners(data);
  }

  @override
  Future<List<OwnerEntity>> getApprovedOwners() async {
    final data = await SyncApi.get("owners/approved");
    return _mapOwners(data);
  }

  @override
  Future<void> addOwner(OwnerEntity owner) async {
    final model = OwnerModel(
      id: owner.id,
      ownerName: owner.ownerName,
      email: owner.email,
      password: owner.password,
      contact: owner.contact,
      status: owner.status,
      isActive: owner.isActive,
      createdAt: owner.createdAt,
      updatedAt: owner.updatedAt,
    );

    await SyncApi.post("owners", model.toMap());
  }

  @override
  Future<void> activateOwner(String ownerId, int durationDays) async {
    await SyncApi.put("owners/$ownerId/activate", {
      "durationDays": durationDays,
    });
  }

  @override
  Future<void> rejectOwner(int ownerId) async {
    await SyncApi.put("owners/$ownerId/reject", {});
  }

  @override
  Future<void> deleteOwner(String ownerId) async {
    await SyncApi.delete("owners/$ownerId");
  }

  @override
  Future<OwnerEntity?> getOwnerByCredentials(
    String email,
    String password, {
    String? activationCode,
  }) async {
    final body = {"email": email, "password": password};

    if (activationCode != null && activationCode.isNotEmpty) {
      body["activationCode"] = activationCode;
    }

    final result = await SyncApi.post(
      "owners/login",
      body,
    ); // adjust endpoint if needed

    if (result == null || result is! Map<String, dynamic>) return null;

    return OwnerModel.fromMap(result);
  }

  @override
  Future<List<OwnerEntity>> getOwnersWithReceipt() async {
    final list = await SyncApi.get("owners/with-receipt");
    return _mapOwners(list);
  }

  @override
  Future<List<OwnerEntity>> getExpiringSubscriptions() async {
    final list = await SyncApi.get("owners/subscriptions/expiring");
    return _mapOwners(list);
  }

  @override
  Future<List<OwnerEntity>> getExpiredSubscriptions() async {
    final list = await SyncApi.get("owners/subscriptions/expired");
    return _mapOwners(list);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingOwnersWithSubscriptions() async {
    final list = await SyncApi.get("owners/pending-with-subscriptions");
    return list.whereType<Map<String, dynamic>>().toList();
  }
}

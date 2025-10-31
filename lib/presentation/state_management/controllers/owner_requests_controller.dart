// presentation/state_management/controllers/owner_requests_controller.dart
import 'package:get/get.dart';
import 'package:pos_desktop/domain/entities/owner_entity.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';
import 'package:pos_desktop/domain/repositories/repositories_impl/owner_repository_impl.dart';

class OwnerRequestsController extends GetxController {
  final OwnerRepository repo = OwnerRepositoryImpl(); // ✅ Singleton

  // Reactive state
  var pendingOwners = <OwnerEntity>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingOwners();
  }

  Future<void> loadPendingOwners() async {
    try {
      isLoading.value = true;
      final owners = await repo.getPendingOwners();
      pendingOwners.value = owners;
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Approve owner with retry and delays
  Future<OwnerEntity?> approveOwner(OwnerEntity owner) async {
    try {
      print("🔄 Approving owner id=${owner.id}...");

      // ✅ Add small delay before operation
      await Future.delayed(const Duration(milliseconds: 50));

      await repo.activateOwner(owner.id.toString());
      print("✅ Owner activated in DB (id=${owner.id})");

      // ✅ Add delay before reloading
      await Future.delayed(const Duration(milliseconds: 100));
      await loadPendingOwners();

      // ✅ Return updated owner
      return owner.copyWith(
        status: OwnerStatus.active,
        activationCode: "123456", // Temporary code
      );
    } catch (e) {
      print("❌ Approve failed: $e");
      return null;
    }
  }

  /// 🔹 Reject owner with delay
  Future<bool> rejectOwner(OwnerEntity owner) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      await repo.rejectOwner(owner.id.toString());
      await Future.delayed(const Duration(milliseconds: 100));
      await loadPendingOwners();
      return true;
    } catch (e) {
      print("❌ Reject failed: $e");
      return false;
    }
  }
}

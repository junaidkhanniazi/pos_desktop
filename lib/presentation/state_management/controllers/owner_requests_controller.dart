// presentation/state_management/controllers/owner_requests_controller.dart
import 'package:get/get.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/domain/entities/owner_entity.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';
import 'package:pos_desktop/domain/repositories/repositories_impl/owner_repository_impl.dart';

class OwnerRequestsController extends GetxController {
  final OwnerRepository repo = OwnerRepositoryImpl();

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

  /// 🔹 Get subscription duration from database - FIXED VERSION
  Future<int> _getSubscriptionDuration(OwnerEntity owner) async {
    try {
      print(
        "🔍 Getting duration for owner's plan: '${owner.subscriptionPlan}'",
      );

      final plans = await repo.getSubscriptionPlans();

      // Debug: Print all available plans
      print("📋 Available plans in database:");
      for (final plan in plans) {
        print("   - '${plan['name']}': ${plan['duration_days']} days");
      }

      // Find the EXACT plan the owner subscribed to
      final ownerPlan = plans.firstWhere(
        (p) =>
            p['name']?.toString().trim() ==
            owner.subscriptionPlan?.toString().trim(),
        orElse: () => {},
      );

      if (ownerPlan.isEmpty) {
        print(
          "❌ CRITICAL: Plan '${owner.subscriptionPlan}' not found in database!",
        );
        print("   Available plans: ${plans.map((p) => p['name']).toList()}");
        throw Exception(
          "Subscription plan '${owner.subscriptionPlan}' not found",
        );
      }

      final duration = ownerPlan['duration_days'] as int? ?? 30;
      print(
        "✅ Using actual plan duration: $duration days for '${owner.subscriptionPlan}'",
      );
      return duration;
    } catch (e) {
      print('❌ Error getting plan duration: $e');
      // Don't use fallback - throw error so we know something is wrong
      throw Exception("Failed to get subscription duration: $e");
    }
  }

  /// 🔹 Approve owner with REAL data - UPDATED to use the fixed method
  Future<OwnerEntity?> approveOwner(OwnerEntity owner) async {
    try {
      print("🔄 Approving owner id=${owner.id}...");

      // ✅ USE THE FIXED METHOD TO GET ACTUAL DURATION
      final durationDays = await _getSubscriptionDuration(owner);

      await repo.activateOwner(
        owner.id.toString(),
        await _getCurrentAdminId(),
        durationDays, // ✅ Now using actual plan duration
      );
      print("✅ Owner activated in DB (id=${owner.id}) with $durationDays days");

      // ✅ Wait for database to update
      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ RELOAD ALL OWNERS TO GET FRESH DATA
      await loadPendingOwners();

      // ✅ GET THE ACTUAL UPDATED OWNER WITH REAL ACTIVATION CODE
      final updatedOwner = await _getUpdatedOwner(owner.id);

      if (updatedOwner != null) {
        print("🎯 Actual activation code: ${updatedOwner.activationCode}");
        return updatedOwner;
      } else {
        print("❌ Could not fetch updated owner data");
        return null;
      }
    } catch (e) {
      print("❌ Approve failed: $e");
      return null;
    }
  }

  /// 🔹 Get the updated owner data from database
  Future<OwnerEntity?> _getUpdatedOwner(String ownerId) async {
    try {
      // Get all approved owners and find our specific one
      final approvedOwners = await repo.getApprovedOwners();
      final updatedOwner = approvedOwners.firstWhere(
        (o) => o.id == ownerId,
        orElse: () => OwnerEntity(
          id: '',
          name: '',
          email: '',
          storeName: '',
          password: '',
          contact: '',
          status: OwnerStatus.pending,
          createdAt: DateTime.now(),
        ),
      );

      // If we found the owner, return it
      return updatedOwner.id.isNotEmpty ? updatedOwner : null;
    } catch (e) {
      print('❌ Error fetching updated owner: $e');
      return null;
    }
  }

  /// 🔹 Get current admin ID from AuthStorageHelper
  Future<String> _getCurrentAdminId() async {
    final adminId = await AuthStorageHelper.getAdminId();
    if (adminId == null) {
      throw Exception("Admin ID not found. Please login again.");
    }
    return adminId;
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

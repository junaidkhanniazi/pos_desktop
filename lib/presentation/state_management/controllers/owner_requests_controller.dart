// presentation/state_management/controllers/owner_requests_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/domain/entities/owner_entity.dart';
import 'package:pos_desktop/domain/entities/subscription_entity.dart';
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

  // Future<void> loadPendingOwners() async {
  //   try {
  //     isLoading.value = true;
  //     final owners = await repo.getPendingOwners();
  //     pendingOwners.value = owners;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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
  Future<OwnerEntity?> approveOwner(
    OwnerEntity owner,
    BuildContext context,
  ) async {
    try {
      print("🔄 Approving owner id=${owner.id}...");

      // ✅ USE THE FIXED METHOD TO GET ACTUAL DURATION
      final durationDays = await _getSubscriptionDuration(owner);

      await repo.activateOwner(
        owner.id.toString(),
        await _getCurrentAdminId(),
        durationDays, // ✅ Now using actual plan duration
        context,
      );
      print("✅ Owner activated in DB (id=${owner.id}) with $durationDays days");

      // ✅ Wait for database to update
      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ RELOAD ALL OWNERS TO GET FRESH DATA
      await loadPendingOwners();

      // ✅ GET THE ACTUAL UPDATED OWNER WITH REAL ACTIVATION CODE
      final updatedOwner = await _getUpdatedOwner(owner.id);

      if (updatedOwner != null) {
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

  // In owner_requests_controller.dart
  Future<void> loadPendingOwners() async {
    try {
      isLoading.value = true;

      // ✅ Get pending owners WITH subscription data in a single query
      final combinedData = await repo.getPendingOwnersWithSubscriptions();

      // Convert the Map data into OwnerEntity list
      final ownersWithSubs = combinedData.map((data) {
        return OwnerEntity(
          id: data['id'].toString(),
          name: data['owner_name']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
          storeName: data['shop_name']?.toString() ?? '',
          contact: data['contact']?.toString() ?? '',
          password: '', // no need to load passwords
          status: OwnerStatus.pending,
          createdAt:
              DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
          subscriptionPlan: data['subscription_plan_name']?.toString(),
          receiptImage: data['receipt_image']?.toString(),
          subscriptionStartDate: data['subscription_start_date'] != null
              ? DateTime.tryParse(data['subscription_start_date'])
              : null,
          subscriptionEndDate: data['subscription_end_date'] != null
              ? DateTime.tryParse(data['subscription_end_date'])
              : null,
        );
      }).toList();

      pendingOwners.value = ownersWithSubs;

      // Debug log
      print('✅ Loaded ${ownersWithSubs.length} pending owners (with plans):');
      for (final o in ownersWithSubs) {
        print('   👤 ${o.name} | Plan: ${o.subscriptionPlan ?? "N/A"}');
      }
    } catch (e) {
      print('❌ Failed to load pending owners with subscriptions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Fetch a specific owner's subscription
  Future<SubscriptionEntity?> getOwnerSubscription(String ownerId) async {
    try {
      final subscription = await repo.getOwnerSubscription(ownerId);
      return subscription;
    } catch (e) {
      print("❌ Error fetching subscription for owner $ownerId: $e");
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

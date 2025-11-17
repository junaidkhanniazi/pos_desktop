import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';
import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';

class OwnerOnboardingController extends GetxController {
  final Logger _logger = Logger();

  // 🔹 Form Controllers
  final formKey = GlobalKey<FormState>();
  final ownerName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final contact = TextEditingController();

  // 🔹 States
  final isLoading = false.obs;
  final plans = <SubscriptionPlanEntity>[].obs;
  final errorMessage = RxnString();
  SubscriptionPlanEntity? selectedPlan;
  File? receiptImage;

  // ===========================================================
  // 🔹 Step 1: Save owner form data locally
  // ===========================================================
  Future<void> saveOwnerForm() async {
    final formData = {
      "ownerName": ownerName.text.trim(),
      "email": email.text.trim(),
      "password": password.text.trim(),
      "contact": contact.text.trim(),
    };
    await AuthStorageHelper.saveTempOwnerData(formData);
    _logger.i("🗂️ Owner form saved temporarily.");
  }

  // ===========================================================
  // 🔹 Step 2: Fetch Subscription Plans
  // ===========================================================
  Future<void> loadPlans() async {
    try {
      isLoading.value = true;
      final list = await SyncApi.get("subscription-plans");
      final mapped = list
          .whereType<Map<String, dynamic>>()
          .map((map) => SubscriptionPlanEntity.fromMap(map))
          .toList();
      plans.assignAll(mapped);
      _logger.i("✅ Loaded ${plans.length} subscription plans");
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;
      _logger.e("❌ Failed to load plans: ${failure.message}");
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================================
  // 🔹 Step 3: Final Registration (API Call)
  // ===========================================================
  Future<void> submitFullRegistration(BuildContext context) async {
    try {
      isLoading.value = true;

      final tempOwner = await AuthStorageHelper.getTempOwnerData();
      if (tempOwner == null) {
        AppToast.show(
          context,
          message: "Owner data missing, please restart registration.",
          type: ToastType.error,
        );
        return;
      }

      if (selectedPlan == null) {
        AppToast.show(
          context,
          message: "Please select a subscription plan.",
          type: ToastType.warning,
        );
        return;
      }

      if (receiptImage == null) {
        AppToast.show(
          context,
          message: "Please upload your payment receipt.",
          type: ToastType.warning,
        );
        return;
      }

      // 🔹 Create unified payload
      final payload = {
        "shopName": tempOwner['shopName'],
        "ownerName": tempOwner['ownerName'],
        "email": tempOwner['email'],
        "password": tempOwner['password'],
        "contact": tempOwner['contact'],
        "subscriptionPlanId": selectedPlan!.id,
        "subscriptionPlanName": selectedPlan!.name,
        "subscriptionAmount": selectedPlan!.price,
        "receiptImage": receiptImage!.path,
      };

      _logger.i("📦 Submitting registration: $payload");

      await SyncApi.post("auth/register", payload);

      await AuthStorageHelper.clearTempOwnerData();

      AppToast.show(
        context,
        message: "Registration submitted for admin approval!",
        type: ToastType.success,
      );

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }

      _logger.i("🎉 Registration flow complete.");
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      _logger.e("❌ Registration failed: ${failure.message}");
      AppToast.show(context, message: failure.message, type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================================
  // 🔹 Form Validation
  // ===========================================================
  String? validateShopName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Shop name is required' : null;
  String? validateOwnerName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Owner name is required' : null;
  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != password.text) return 'Passwords do not match';
    return null;
  }

  String? validateContact(String? v) {
    if (v == null || v.isEmpty) return 'Contact number required';
    if (v.length < 10) return 'Enter a valid contact number';
    return null;
  }

  // ===========================================================
  // 🔹 Helpers
  // ===========================================================
  void clearForm() {
    ownerName.clear();
    email.clear();
    password.clear();
    confirmPassword.clear();
    contact.clear();
  }

  @override
  void onClose() {
    ownerName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    contact.dispose();
    super.onClose();
  }
}

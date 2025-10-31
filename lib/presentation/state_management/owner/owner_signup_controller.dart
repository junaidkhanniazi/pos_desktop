import 'package:flutter/material.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/core/utils/validators.dart';
import 'package:pos_desktop/domain/entities/owner_entity.dart';
import 'package:pos_desktop/domain/usecases/add_owner_usecase.dart';
import 'package:pos_desktop/domain/repositories/owner_repository.dart';

/// Handles the logic for OwnerSignupScreen
class OwnerSignupController {
  final AddOwnerUseCase _addOwnerUseCase;

  OwnerSignupController(OwnerRepository repository)
    : _addOwnerUseCase = AddOwnerUseCase(repository);

  // --- Text controllers ---
  final shopName = TextEditingController();
  final ownerName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final contact = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // --- Validation methods ---
  String? validateShopName(String? v) =>
      Validators.notEmpty(v, fieldName: 'Shop Name');
  String? validateOwnerName(String? v) =>
      Validators.notEmpty(v, fieldName: 'Owner Name');

  String? validateEmail(String? v) {
    final err = Validators.notEmpty(v, fieldName: 'Email');
    if (err != null) return err;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(v!)) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? v) {
    final err = Validators.notEmpty(v, fieldName: 'Password');
    if (err != null) return err;
    if (v!.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String? v) {
    final err = Validators.notEmpty(v, fieldName: 'Confirm Password');
    if (err != null) return err;
    if (v != password.text) return 'Passwords do not match';
    return null;
  }

  String? validateContact(String? v) {
    if (v == null || v.isEmpty)
      return 'Contact number is required'; // ✅ ADDED: Now required
    final regex = RegExp(r'^[0-9+\-\s()]{10,}$');
    if (!regex.hasMatch(v)) return 'Enter a valid contact number';
    return null;
  }

  // --- Signup handler ---
  Future<void> signup(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    // ✅ Create OwnerEntity with ALL required fields
    final entity = OwnerEntity(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // ✅ Generate unique ID
      name: ownerName.text.trim(),
      email: email.text.trim(),
      storeName: shopName.text.trim(),
      password: password.text.trim(), // ✅ ADDED: Required field
      contact: contact.text.trim(), // ✅ ADDED: Required field
      superAdminId: null, // ✅ ADDED: Can be null
      status: OwnerStatus.pending,
      createdAt: DateTime.now(),
      activationCode: null, // ✅ ADDED: Can be null
      subscriptionPlan: null, // Will be set in payment screen
      receiptImage: null, // Will be set in payment screen
      paymentDate: null, // Will be set in payment screen
      subscriptionAmount: null, // Will be set in payment screen
      subscriptionStartDate: null, // Will be set when approved
      subscriptionEndDate: null, // Will be set when approved
    );

    try {
      await _addOwnerUseCase.call(entity);
      AppToast.show(
        context,
        message:
            'Registration submitted successfully! Wait for admin approval.',
        type: ToastType.success,
      );
      clearForm();
    } catch (e) {
      AppToast.show(
        context,
        message: 'Failed to register owner: $e',
        type: ToastType.error,
      );
    }
  }

  // ✅ ADDED: Method to get form data for navigation to payment screen
  Map<String, String> getFormData() {
    return {
      'shopName': shopName.text.trim(),
      'ownerName': ownerName.text.trim(),
      'email': email.text.trim(),
      'password': password.text.trim(),
      'contact': contact.text.trim(),
    };
  }

  void clearForm() {
    shopName.clear();
    ownerName.clear();
    email.clear();
    password.clear();
    confirmPassword.clear();
    contact.clear();
  }

  void dispose() {
    shopName.dispose();
    ownerName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    contact.dispose();
  }
}

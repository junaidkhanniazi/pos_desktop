import 'package:flutter/material.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/core/utils/validators.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/domain/repositories/repositories_impl/auth_repository_impl.dart';
import 'package:pos_desktop/domain/usecases/login_usecase.dart';
import 'package:pos_desktop/data/local/dao/super_admin_dao.dart';
import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:pos_desktop/data/local/dao/user_dao.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';

class LoginController {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final LoginUseCase _useCase = LoginUseCase(
    AuthRepositoryImpl(SuperAdminDao(), OwnerDao(), UserDao()),
  );

  /// 🔹 Main Login Method (handles SuperAdmin, Owner, Staff)
  Future<void> login(BuildContext context) async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    final emailError = Validators.notEmpty(email, fieldName: 'Email');
    final passError = Validators.notEmpty(password, fieldName: 'Password');

    if (emailError != null || passError != null) {
      AppToast.show(
        context,
        message: emailError ?? passError!,
        type: ToastType.warning,
      );
      return;
    }

    _isLoading = true;

    try {
      final role = await _useCase(email, password);

      switch (role) {
        case AuthRole.superAdmin:
          final adminResult = await SuperAdminDao().login(email, password);
          if (adminResult != null) {
            await AuthStorageHelper.saveLogin(
              role: AuthRole.superAdmin,
              email: email,
              adminId: adminResult['id'].toString(),
            );
          }
          if (!context.mounted) return;
          AppToast.show(
            context,
            message: "Super Admin login successful",
            type: ToastType.success,
          );
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.superAdminDashboard,
          );
          break;

        case AuthRole.owner:
          try {
            // First check if owner exists and subscription status
            final ownerDao = OwnerDao();
            final owner = await ownerDao.getOwnerByCredentials(email, password);

            if (owner != null) {
              if (owner.isSubscriptionExpired) {
                // Subscription expired error message
                AppToast.show(
                  context,
                  message:
                      'Your subscription has expired. Please renew to continue.',
                  type: ToastType.error,
                );
                return; // Prevent login
              }

              if (owner.isSubscriptionExpiringSoon) {
                final daysLeft = DateTime.parse(
                  owner.subscriptionEndDate!,
                ).difference(DateTime.now()).inDays;
                if (!context.mounted) return;
                AppToast.show(
                  context,
                  message:
                      'Your subscription expires in $daysLeft days. Please renew soon.',
                  type: ToastType.warning,
                );
              }

              await AuthStorageHelper.saveLogin(
                role: AuthRole.owner,
                email: email,
              );

              _showActivationDialog(context, email, password);
            }
          } catch (e) {
            // Check if the error is related to expired subscription
            if (e.toString().contains('subscription has expired')) {
              AppToast.show(
                context,
                message:
                    'Your subscription has expired. Please renew to continue.',
                type: ToastType.error,
              );
            } else {
              // Handle other errors
              AppToast.show(
                context,
                message: 'Owner login failed: ${e.toString()}',
                type: ToastType.error,
              );
            }
            return;
          }
          break;

        case AuthRole.staff:
          final staffRole = await AuthStorageHelper.getStaffRole() ?? 'cashier';
          if (!context.mounted) return;
          AppToast.show(
            context,
            message: "Staff ($staffRole) login successful",
            type: ToastType.success,
          );

          switch (staffRole.toLowerCase()) {
            case 'cashier':
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.cashierDashboard,
              );
              break;
            case 'accountant':
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.accountantDashboard,
              );
              break;
            case 'manager':
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.inventoryManagerDashboard,
              );
              break;
            default:
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.cashierDashboard,
              );
          }
          break;
      }
    } catch (e) {
      if (!context.mounted) return;

      // Only show error if it's not already handled (like expired subscription)
      if (!e.toString().contains('subscription has expired')) {
        AppToast.show(
          context,
          message: 'Subscription has expired. Please renew to continue.',
          type: ToastType.error,
        );
      }
    } finally {
      _isLoading = false;
    }
  }

  /// 🔸 Show activation popup for Owner
  void _showActivationDialog(
    BuildContext context,
    String email,
    String password,
  ) {
    final activationCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Activation Code Required", style: AppText.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please enter your activation code to login as Owner.",
              style: AppText.body.copyWith(color: AppColors.textMedium),
            ),
            const SizedBox(height: 16),
            AppInput(
              controller: activationCtrl,
              hint: "Enter Activation Code",
              type: InputType.text,
            ),
          ],
        ),
        actions: [
          AppButton(
            label: "Cancel",
            onPressed: () => Navigator.pop(ctx),
            isPrimary: false,
          ),
          AppButton(
            label: "Verify & Login",
            onPressed: () async {
              await _verifyOwnerLogin(
                ctx,
                email,
                password,
                activationCtrl.text.trim(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🔸 Verify Owner Activation
  Future<void> _verifyOwnerLogin(
    BuildContext context,
    String email,
    String password,
    String activationCode,
  ) async {
    final codeError = Validators.notEmpty(
      activationCode,
      fieldName: 'Activation Code',
    );
    if (codeError != null) {
      AppToast.show(context, message: codeError, type: ToastType.warning);
      return;
    }

    try {
      final ownerDao = OwnerDao();
      final verified = await ownerDao.getOwnerByCredentials(
        email,
        password,
        activationCode: activationCode,
      );

      if (verified != null) {
        if (verified.isSubscriptionExpired) {
          AppToast.show(
            context,
            message: 'Your subscription has expired. Please renew to continue.',
            type: ToastType.error,
          );
          return; // Stop activation if expired
        }

        await AuthStorageHelper.saveLogin(role: AuthRole.owner, email: email);

        if (!context.mounted) return;
        Navigator.pop(context);

        if (verified.isSubscriptionExpiringSoon) {
          final daysLeft = DateTime.parse(
            verified.subscriptionEndDate!,
          ).difference(DateTime.now()).inDays;

          AppToast.show(
            context,
            message:
                'Your subscription expires in $daysLeft days. Please renew soon.',
            type: ToastType.warning,
          );
        }

        AppToast.show(
          context,
          message: "Owner login successful!",
          type: ToastType.success,
        );
        Navigator.pushReplacementNamed(context, AppRoutes.ownerDashboard);
      } else {
        AppToast.show(
          context,
          message: "Invalid activation code",
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (e.toString().contains('subscription has expired')) {
        AppToast.show(
          context,
          message: 'Your subscription has expired. Please renew to continue.',
          type: ToastType.error,
        );
      } else {
        AppToast.show(
          context,
          message: "Login failed: $e",
          type: ToastType.error,
        );
      }
    }
  }

  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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
import 'package:pos_desktop/data/local/dao/subscription_dao.dart';

class LoginController {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _logger = Logger();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final LoginUseCase _useCase = LoginUseCase(
    AuthRepositoryImpl(SuperAdminDao(), OwnerDao(), UserDao()),
  );

  /// 🔹 Main Login Method (SuperAdmin, Owner, Staff)
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
          await _handleOwnerLogin(context, email, password);
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
      AppToast.show(
        context,
        message: 'Login failed: $e',
        type: ToastType.error,
      );
    } finally {
      _isLoading = false;
    }
  }

  /// 🔹 OWNER LOGIN (Subscription Validation + Status Check)
  Future<void> _handleOwnerLogin(
    BuildContext context,
    String email,
    String password,
  ) async {
    final ownerDao = OwnerDao();
    final subDao = SubscriptionDao();

    final owner = await ownerDao.getOwnerByCredentials(email, password);
    if (owner == null) {
      AppToast.show(
        context,
        message: "Invalid owner credentials",
        type: ToastType.error,
      );
      return;
    }

    final sub = await subDao.getActiveSubscription(owner.id!);

    // 🔴 No subscription found
    if (sub == null) {
      AppToast.show(
        context,
        message: 'No active subscription found. Please contact admin.',
        type: ToastType.error,
      );
      return;
    }

    // 🔴 Subscription inactive or expired
    if (sub.status == 'inactive' || sub.isExpired) {
      AppToast.show(
        context,
        message:
            'Your subscription has expired or is inactive. Please renew to continue.',
        type: ToastType.error,
      );
      return;
    }

    // 🟡 Expiring soon (show warning, still allow login)
    if (sub.isExpiringSoon) {
      final daysLeft = sub.subscriptionEndDate != null
          ? DateTime.parse(
              sub.subscriptionEndDate!,
            ).difference(DateTime.now()).inDays
          : 0;

      if (!context.mounted) return;
      AppToast.show(
        context,
        message:
            'Your subscription expires in $daysLeft days. Please renew soon.',
        type: ToastType.warning,
      );
    }

    // ✅ Valid subscription — proceed with login
    await AuthStorageHelper.saveLogin(
      role: AuthRole.owner,
      email: email,
      ownerId: owner.id.toString(),
    );

    if (!context.mounted) return;

    AppToast.show(
      context,
      message: "Owner login successful!",
      type: ToastType.success,
    );

    Navigator.pushReplacementNamed(context, AppRoutes.ownerDashboard);
  }

  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
  }
}

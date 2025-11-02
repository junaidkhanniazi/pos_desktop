import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart'; // ✅ ADD THIS
import 'package:pos_desktop/core/utils/toast_helper.dart'; // ✅ ADD THIS
import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/domain/repositories/repositories_impl/auth_repository_impl.dart';
import 'package:pos_desktop/domain/usecases/login_usecase.dart';
import 'package:pos_desktop/data/local/dao/super_admin_dao.dart';
import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:pos_desktop/data/local/dao/user_dao.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final LoginUseCase _loginUseCase;

  @override
  void initState() {
    super.initState();

    _loginUseCase = LoginUseCase(
      AuthRepositoryImpl(SuperAdminDao(), OwnerDao(), UserDao()),
    );

    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 1));

    // ✅ FIRST CHECK IF SUBSCRIPTION EXPIRED AND AUTO LOGOUT
    final shouldRedirect = await AuthStorageHelper.shouldRedirectToLogin();

    if (shouldRedirect && mounted) {
      // Subscription expired, show message and go to login
      _showExpirationMessageAndRedirect();
      return;
    }

    // ✅ THEN CHECK SAVED LOGIN ROLE (NORMAL FLOW)
    final role = await LoginUseCase.checkAutoLogin();

    if (!mounted) return;

    if (role != null) {
      _navigateToRole(context, role);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // ✅ SHOW EXPIRATION MESSAGE AND REDIRECT TO LOGIN
  void _showExpirationMessageAndRedirect() {
    // Show expiration message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppToast.show(
        context,
        message: 'Your subscription has expired. Please renew to continue.',
        type: ToastType.error,
      );
    });

    // Redirect to login after short delay
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  void _navigateToRole(BuildContext context, AuthRole role) {
    switch (role) {
      case AuthRole.superAdmin:
        Navigator.pushReplacementNamed(context, AppRoutes.superAdminDashboard);
        break;
      case AuthRole.owner:
        Navigator.pushReplacementNamed(context, AppRoutes.ownerDashboard);
        break;
      case AuthRole.staff:
        Navigator.pushReplacementNamed(context, AppRoutes.cashierDashboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "POS System",
              style: AppText.h1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text("Loading workspace...", style: AppText.small),
          ],
        ),
      ),
    );
  }
}

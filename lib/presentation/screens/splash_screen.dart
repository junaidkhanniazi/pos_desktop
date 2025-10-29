import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
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

    // ✅ Initialize with repository
    _loginUseCase = LoginUseCase(
      AuthRepositoryImpl(SuperAdminDao(), OwnerDao(), UserDao()),
    );

    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 1)); // smooth splash delay

    // ✅ Check saved login role
    final role = await LoginUseCase.checkAutoLogin();

    if (!mounted) return;

    // ✅ Navigate based on saved role
    if (role != null) {
      _navigateToRole(context, role);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
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
        // ⚠️ For now default to cashier, can later refine using saved staff subrole
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

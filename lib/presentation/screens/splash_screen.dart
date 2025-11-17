import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/data/remote/sync/sync_service.dart';
import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthStorageHelper _authHelper = AuthStorageHelper();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2)); // Small splash delay

    final isLoggedIn = await AuthStorageHelper.isLoggedIn();
    if (!isLoggedIn) {
      _goToLogin();
      return;
    }

    final role = await AuthStorageHelper.getRole();
    if (role == null) {
      _goToLogin();
      return;
    }

    // ✅ Go to appropriate dashboard
    await _goToDashboard(role);
  }

  Future<void> _goToDashboard(AuthRole role) async {
    switch (role) {
      case AuthRole.superAdmin:
        Get.offAllNamed(AppRoutes.superAdminDashboard);
        break;

      case AuthRole.owner:
        // ✅ Initialize SQLite FFI
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;

        // ✅ Perform Sync for owner
        try {
          final syncService = SyncService();
          await syncService.performInitialSyncForExistingData();
          syncService.startAutoSync();
          debugPrint('✅ Sync initialized successfully');
        } catch (e) {
          debugPrint('❌ Sync initialization failed: $e');
        }

        // ✅ Navigate to Owner Dashboard after sync setup
        Get.offAllNamed(AppRoutes.ownerDashboard);
        break;

      default:
        _goToLogin();
    }
  }

  void _goToLogin() {
    Get.offAllNamed(AppRoutes.login);
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

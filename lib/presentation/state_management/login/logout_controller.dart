// lib/presentation/controllers/logout_controller.dart
import 'package:flutter/material.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
// 👇 make sure yeh sahi helper import ho
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';

class LogoutController {
  Future<void> logout(BuildContext context) async {
    await AuthStorageHelper.logout(); // <- yahan logout()l
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );

    AppToast.show(
      context,
      message: 'Logged out successfully',
      type: ToastType.success,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/data/local/dao/super_admin_dao.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DatabaseHelper().database;

  final dao = SuperAdminDao();
  await dao.insertSuperAdmin(
    name: 'System Admin',
    email: 'admin@pos.app',
    password: 'admin123',
  );

  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.ownerSignup,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

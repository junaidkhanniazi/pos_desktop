import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/local/dao/super_admin_dao.dart';
import 'package:pos_desktop/data/local/dao/subscription_plan_dao.dart';
import 'package:pos_desktop/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  final database = await dbHelper.database; // ✅ Initialize main DB

  // ✅ Ensure Super Admin exists
  final superAdminDao = SuperAdminDao();
  await superAdminDao.insertSuperAdmin(
    name: 'System Admin',
    email: 'admin@pos.app',
    password: 'admin123',
  );

  // ✅ Initialize Subscription Plans Table only
  final subscriptionPlanDao = SubscriptionPlanDao(database);
  await subscriptionPlanDao.createTable();

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
      home: const SplashScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

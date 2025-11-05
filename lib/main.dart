import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/data/local/dao/owner_dao.dart' show OwnerDao;
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/local/dao/super_admin_dao.dart';
import 'package:pos_desktop/data/local/dao/subscription_plan_dao.dart';
import 'package:pos_desktop/data/remote/sync/sync_service.dart';
import 'package:pos_desktop/presentation/screens/splash_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  final database = await dbHelper.database; // ✅ Initialize system DB
  final syncService = SyncService(ownerName: 'junaid'); // 👈 Add ownerName
  // ====== Add push/pull calls here ======
  final storeDbPath =
      'C:/Users/Admin/Documents/Pos_Desktop/pos_data/junaid/junaid_junaid_sweets/store.db';
  await syncService.pushDatabase(storeDbPath); // Push all unsynced rows
  await syncService.pullDatabase(storeDbPath, [
    'products',
    'customers',
  ]); // Pull latest data
  // =====================================

  // await syncService.scanUnsyncedData(
  //   'C:\\Users\\Admin\\Documents\\Pos_Desktop\\pos_data\\junaid\\junaid_junaid_tailor\\store.db',
  // );
  // await syncService.pushUnsyncedData(
  //   'C:\\Users\\Admin\\Documents\\Pos_Desktop\\pos_data\\junaid\\junaid_junaid_tailor\\store.db',
  // );
  // await syncService.pullFromServer(
  //   'C:\\Users\\Admin\\Documents\\Pos_Desktop\\pos_data\\junaid\\junaid_junaid_tailor\\store.db',
  // );

  // ✅ Ensure Super Admin exists
  final superAdminDao = SuperAdminDao();
  final ownerDao = OwnerDao();

  // await ownerDao.createTestExpiredOwner();

  await superAdminDao.insertSuperAdmin(
    name: 'System Admin',
    email: 'admin@pos.app',
    password: 'admin123',
  );

  // ✅ Initialize Subscription Plans Table only
  final subscriptionPlanDao = SubscriptionPlanDao(database);
  await subscriptionPlanDao.createTable();
  // await debugAllDbs();

  // ✅ VERIFY STORE SCHEMA (this actually runs now)

  runApp(const POSApp());
}

Future<void> debugAllDbs() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  print('============================');
  print('🔍 VERIFYING ALL DATABASES');
  print('============================');

  final documentsDir = await getApplicationDocumentsDirectory();
  final posDesktopFolder = Directory(join(documentsDir.path, 'Pos_Desktop'));

  // 🔹 1. SYSTEM DB
  final systemPath = join(posDesktopFolder.path, 'pos_system.db');
  final systemDb = await databaseFactoryFfi.openDatabase(systemPath);
  print('\n📘 SYSTEM DB → $systemPath');
  final sysTables = await systemDb.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table'",
  );
  for (final t in sysTables) {
    final name = t['name'];
    print('  📋 $name');
    final info = await systemDb.rawQuery('PRAGMA table_info($name)');
    for (final c in info) {
      print('     - ${c['name']} | ${c['type']}');
    }
  }
  await systemDb.close();

  // 🔹 2. MASTER DBs (per owner)
  final posDataFolder = Directory(join(posDesktopFolder.path, 'pos_data'));
  if (!await posDataFolder.exists()) {
    print('\n❌ No pos_data folder found (no owners yet)');
    return;
  }

  final ownerFolders = posDataFolder.listSync();
  for (final ownerFolder in ownerFolders.whereType<Directory>()) {
    final ownerName = basename(ownerFolder.path);
    print('\n👤 OWNER: $ownerName');

    // Master DB
    final masterPath = join(ownerFolder.path, '${ownerName}_master.db');
    if (await File(masterPath).exists()) {
      final masterDb = await databaseFactoryFfi.openDatabase(masterPath);
      print('  💽 MASTER DB → $masterPath');
      final masterTables = await masterDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      for (final t in masterTables) {
        final name = t['name'];
        print('    📋 $name');
        final info = await masterDb.rawQuery('PRAGMA table_info($name)');
        for (final c in info) {
          print('       - ${c['name']} | ${c['type']}');
        }
      }
      await masterDb.close();
    } else {
      print('  ⚠️ Master DB missing for $ownerName');
    }

    // 🔹 3. STORE DBs
    final ownerEntities = ownerFolder.listSync();
    for (final entity in ownerEntities.whereType<Directory>()) {
      final storeName = basename(entity.path);
      final storeDbPath = join(entity.path, 'store.db');
      if (await File(storeDbPath).exists()) {
        final storeDb = await databaseFactoryFfi.openDatabase(storeDbPath);
        print('  🏪 STORE DB → $storeName');
        final storeTables = await storeDb.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'",
        );
        for (final t in storeTables) {
          final name = t['name'];
          print('    📋 $name');
          final info = await storeDb.rawQuery('PRAGMA table_info($name)');
          for (final c in info) {
            print('       - ${c['name']} | ${c['type']}');
          }
        }
        await storeDb.close();
      }
    }
  }

  print('\n============================');
  print('✅ ALL DATABASES VERIFIED!');
  print('============================');
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/data/remote/sync/sync_service.dart';
import 'package:pos_desktop/injection.dart';
import 'package:pos_desktop/presentation/screens/login_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  setupDependencies();
  try {
    final syncService = SyncService();
    await syncService.performInitialSyncForExistingData();
    syncService.startAutoSync();
  } catch (e) {
    debugPrint('❌ Sync initialization failed: $e');
  }

  // ✅ RUN FLUTTER APP
  runApp(const POSApp());
}

Future<void> debugAllDbs() async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final posDesktopFolder = Directory(join(documentsDir.path, 'Pos_Desktop'));

  // 🔹 1. SYSTEM DB
  final systemPath = join(posDesktopFolder.path, 'pos_system.db');
  final systemDb = await databaseFactoryFfi.openDatabase(systemPath);

  final sysTables = await systemDb.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table'",
  );
  for (final t in sysTables) {
    final name = t['name'];
    await systemDb.rawQuery('PRAGMA table_info($name)');
  }
  await systemDb.close();

  // 🔹 2. MASTER DBs (per owner)
  final posDataFolder = Directory(join(posDesktopFolder.path, 'pos_data'));

  final ownerFolders = posDataFolder.listSync();
  for (final ownerFolder in ownerFolders.whereType<Directory>()) {
    final ownerName = basename(ownerFolder.path);

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
        await masterDb.rawQuery('PRAGMA table_info($name)');
      }
      await masterDb.close();
    }

    // 🔹 3. STORE DBs
    final ownerEntities = ownerFolder.listSync();
    for (final entity in ownerEntities.whereType<Directory>()) {
      basename(entity.path);
      final storeDbPath = join(entity.path, 'store.db');
      if (await File(storeDbPath).exists()) {
        final storeDb = await databaseFactoryFfi.openDatabase(storeDbPath);
        final storeTables = await storeDb.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'",
        );
        for (final t in storeTables) {
          final name = t['name'];
          await storeDb.rawQuery('PRAGMA table_info($name)');
        }
        await storeDb.close();
      }
    }
  }
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'POS System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

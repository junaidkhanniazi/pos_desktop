// import 'dart:async';
// import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
// import 'package:pos_desktop/data/remote/api/sync_api.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:logger/logger.dart';

// class SyncService {
//   // 🔹 Sirf is liye banaya hai taake DatabaseHelper ka constructor chale
//   // aur sqfliteFfiInit + databaseFactory set ho jaye.

//   final _logger = Logger();

//   // ✅ Initial full sync (push local data that’s not synced yet)
//   Future<void> performInitialSyncForExistingData() async {
//     _logger.i("🚀 Starting initial full sync (local → server)");

//     try {
//       await _pushUnsynced();
//       _logger.i("✅ Initial sync completed successfully for all databases");
//     } catch (e) {
//       _logger.e("❌ Initial sync failed: $e");
//     }
//   }

//   // 🔄 Auto Sync starter — runs periodically or on connectivity changes
//   void startAutoSync() {
//     _logger.i("🔁 Auto sync service started");

//     // Connectivity listener
//     Connectivity().onConnectivityChanged.listen((status) {
//       if (status != ConnectivityResult.none) {
//         _logger.i("🌐 Network available — running sync");
//         syncAllData();
//       } else {
//         _logger.w("⚠️ Offline — sync paused");
//       }
//     });

//     // Periodic background sync every 10 minutes
//     Timer.periodic(const Duration(minutes: 10), (timer) async {
//       final connectivity = await Connectivity().checkConnectivity();
//       if (connectivity != ConnectivityResult.none) {
//         _logger.i("🕓 Periodic sync triggered");
//         await syncAllData();
//       }
//     });
//   }

//   // 🔁 Combined sync: push + pull for all offline DBs (master + stores)
//   Future<void> syncAllData() async {
//     _logger.i("🔁 Sync cycle started (push + pull)");
//     await _pushUnsynced();
//     // await _pullUpdates();
//     _logger.i("✅ Sync cycle finished");
//   }

//   // 🔼 PUSH unsynced local data
//   Future<void> _pushUnsynced() async {
//     try {
//       final ownerIdStr =
//           await AuthStorageHelper.getOwnerId(); // ✅ Get saved ownerId
//       if (ownerIdStr == null) {
//         _logger.w("⚠️ No ownerId found — skipping push sync.");
//         return;
//       }
//       final ownerId = int.tryParse(ownerIdStr);
//       if (ownerId == null) {
//         _logger.w("⚠️ Invalid ownerId: $ownerIdStr");
//         return;
//       }

//       final databases = await _getAllDatabases();
//       if (databases.isEmpty) {
//         _logger.w("⚠️ No databases found for sync!");
//         return;
//       }

//       for (final dbFile in databases) {
//         final dbPath = dbFile.path;
//         final dbName = basename(dbPath);
//         _logger.i("⬆️ Pushing unsynced data for DB: $dbName");

//         final db = await databaseFactoryFfi.openDatabase(dbPath);

//         List<String> tables;
//         if (dbName == 'master.db') {
//           tables = ['stores'];
//         } else {
//           tables = [
//             'brands',
//             'categories',
//             'customers',
//             'expenses',
//             'products',
//             'sales',
//             'sale_items',
//             'suppliers',
//           ];
//         }

//         for (final table in tables) {
//           try {
//             final unsyncedRows = await db.query(table, where: 'is_synced = 0');
//             if (unsyncedRows.isEmpty) continue;

//             _logger.i(
//               "📤 Syncing ${unsyncedRows.length} from $table ($dbName)",
//             );

//             for (final row in unsyncedRows) {
//               try {
//                 final payload = Map<String, dynamic>.from(row);
//                 payload.remove('is_synced');
//                 payload.remove('last_updated');

//                 // ✅ Inject ownerId if missing
//                 payload['ownerId'] ??= ownerId;

//                 await SyncApi.post("sync/$table", payload);

//                 await db.update(
//                   table,
//                   {'is_synced': 1},
//                   where: 'id = ?',
//                   whereArgs: [row['id']],
//                 );

//                 _logger.i("✅ Synced $table → row ${row['id']} from $dbName");
//               } catch (e) {
//                 _logger.e("❌ Failed to sync $table record ${row['id']}: $e");
//               }
//             }
//           } catch (e) {
//             _logger.w("⚠️ Table missing or invalid in $dbName: $table ($e)");
//           }
//         }
//       }

//       _logger.i("✅ Local push completed for all databases");
//     } catch (e) {
//       _logger.e("❌ Push sync error: $e");
//     }
//   }

//   // 🔽 PULL server updates
//   // Future<void> _pullUpdates() async {
//   //   try {
//   //     final ownerIdStr =
//   //         await AuthStorageHelper.getOwnerId(); // ✅ Fetch ownerId
//   //     if (ownerIdStr == null) {
//   //       _logger.w("⚠️ No ownerId found — skipping pull sync.");
//   //       return;
//   //     }

//   //     final databases = await _getAllDatabases();
//   //     if (databases.isEmpty) {
//   //       _logger.w("⚠️ No databases found for pull sync!");
//   //       return;
//   //     }

//   //     for (final dbFile in databases) {
//   //       final dbPath = dbFile.path;
//   //       final dbName = basename(dbPath);
//   //       _logger.i("⬇️ Pulling updates for DB: $dbName");

//   //       final db = await databaseFactoryFfi.openDatabase(dbPath);

//   //       List<String> tables;
//   //       if (dbName == 'master.db') {
//   //         tables = ['stores'];
//   //       } else {
//   //         tables = []; // (You can add others later if needed)
//   //       }

//   //       for (final table in tables) {
//   //         try {
//   //           // ✅ Now pass ownerId in query
//   //           final remoteData = await SyncApi.get(
//   //             "sync/$table?ownerId=$ownerIdStr",
//   //           );

//   //           if (remoteData.isEmpty) continue;

//   //           _logger.i(
//   //             "⬇️ Received ${remoteData.length} rows for $table ($dbName)",
//   //           );

//   //           for (final row in remoteData) {
//   //             await db.insert(
//   //               table,
//   //               row,
//   //               conflictAlgorithm: ConflictAlgorithm.replace,
//   //             );
//   //           }
//   //         } catch (e) {
//   //           _logger.w("⚠️ Pull failed for $table in $dbName: $e");
//   //         }
//   //       }
//   //     }

//   //     _logger.i("✅ Cloud pull completed for all databases");
//   //   } catch (e) {
//   //     _logger.e("❌ Pull sync error: $e");
//   //   }
//   // }

//   // 🗂️ Helper → Get all existing .db files from Pos_Desktop/owners/...
//   Future<List<File>> _getAllDatabases() async {
//     final List<File> dbFiles = [];
//     final appDir = await getApplicationDocumentsDirectory();
//     final posDesktopDir = Directory(join(appDir.path, 'Pos_Desktop'));

//     if (!await posDesktopDir.exists()) {
//       _logger.w("⚠️ Pos_Desktop folder not found: ${posDesktopDir.path}");
//       return [];
//     }

//     // ❌ Pehle yahan system DB add kar rahe the:
//     // final systemDbPath = join(posDesktopDir.path, 'pos_system.db');
//     // Ab system DB use hi nahi ho raha, is liye ye block hata diya.

//     // ✅ Owner-level databases (master.db) + store DBs
//     final ownersDir = Directory(join(posDesktopDir.path, 'owners'));
//     if (await ownersDir.exists()) {
//       final ownerFolders = ownersDir.listSync().whereType<Directory>();
//       for (final ownerFolder in ownerFolders) {
//         // 1) master.db
//         final masterPath = join(ownerFolder.path, 'master.db');
//         if (File(masterPath).existsSync()) {
//           _logger.i("👤 Found master DB: $masterPath");
//           dbFiles.add(File(masterPath));
//         }

//         // 2) each store DB
//         final storesDir = Directory(join(ownerFolder.path, 'stores'));
//         if (await storesDir.exists()) {
//           final storeFiles = storesDir
//               .listSync()
//               .whereType<File>()
//               .where((f) => f.path.endsWith('.db'))
//               .toList();

//           for (final f in storeFiles) {
//             _logger.i("🏪 Found store DB: ${f.path}");
//             dbFiles.add(f);
//           }
//         }
//       }
//     }

//     _logger.i("📦 Total DB files found for sync: ${dbFiles.length}");
//     return dbFiles;
//   }

//   Future<void> _markRowSynced(Database db, String table, int id) async {
//     await db.update(
//       table,
//       {'is_synced': 1, 'last_updated': DateTime.now().toIso8601String()},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SyncService {
  final _logger = Logger();
  final _dbHelper = DatabaseHelper();

  bool _isAutoSyncing = false;
  Timer? _autoSyncTimer;

  // =========================================================
  // ✅ 1. Perform Initial Full Sync
  // =========================================================
  Future<void> performInitialSyncForExistingData() async {
    _logger.i('🚀 Starting initial full sync (local → server)');
    final dbFiles = await _getAllDatabases();

    if (dbFiles.isEmpty) {
      _logger.w('⚠️ No databases found for sync.');
      return;
    }

    _logger.i('📦 Total DB files found for sync: ${dbFiles.length}');
    for (final file in dbFiles) {
      final db = await databaseFactoryFfi.openDatabase(file.path);
      await _pushUnsynced(db, file);
    }

    _logger.i('✅ Initial sync completed successfully for all databases');
  }

  // =========================================================
  // ✅ 2. Auto Sync Every 30 Seconds
  // =========================================================
  void startAutoSync() {
    if (_isAutoSyncing) return;
    _isAutoSyncing = true;

    _logger.i('🔁 Auto sync service started');

    _autoSyncTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        if (await _isNetworkAvailable()) {
          _logger.i('🌐 Network available — running sync');
          await syncAllData();
        } else {
          _logger.w('🚫 Network unavailable — skipping sync cycle');
        }
      } catch (e) {
        _logger.e('❌ Auto sync failed: $e');
      }
    });
  }

  // =========================================================
  // ✅ 3. Full Sync Cycle
  // =========================================================
  Future<void> syncAllData() async {
    _logger.i('🔁 Sync cycle started (push + pull)');
    final dbFiles = await _getAllDatabases();

    for (final file in dbFiles) {
      final db = await databaseFactoryFfi.openDatabase(file.path);
      await _pushUnsynced(db, file);
      await _pullUpdates(db, file);
    }

    _logger.i('✅ Sync cycle finished');
  }

  // =========================================================
  // ✅ 4. PUSH UNSYNCED DATA
  // =========================================================
  Future<void> _pushUnsynced(Database db, File file) async {
    final dbName = basename(file.path);
    _logger.i('⬆️ Pushing unsynced data for DB: $dbName');

    final tables = [
      'stores',
      'categories',
      'brands',
      'products',
      'customers',
      'expenses',
      'sales',
      'sale_items',
      'suppliers',
    ];

    for (final table in tables) {
      try {
        final rows = await db.query(table, where: 'is_synced = 0');

        if (rows.isEmpty) continue;

        _logger.i('📤 Syncing ${rows.length} from $table ($dbName)');

        for (final row in rows) {
          try {
            final response = await SyncApi.post(table, row);
            _logger.i('✅ POST success: $response');

            if (response['success'] == true && row['id'] != null) {
              await _markRowSynced(db, table, row['id']);
              _logger.i('✅ Marked row ${row['id']} as synced in $table');
            }
          } catch (e) {
            _logger.e('❌ Failed to sync $table row ${row['id']}: $e');
          }
        }

        _logger.i('✅ Synced $table → ${rows.length} rows from $dbName');
      } catch (e) {
        _logger.e('❌ Error syncing $table: $e');
      }
    }

    _logger.i('✅ Local push completed for all databases');
  }

  // =========================================================
  // ✅ 5. PULL UPDATES (Server → Local)
  // =========================================================
  Future<void> _pullUpdates(Database db, File file) async {
    final dbName = basename(file.path);
    _logger.i('⬇️ Pulling updates for DB: $dbName');

    final tables = [
      'stores',
      'categories',
      'brands',
      'products',
      'customers',
      'expenses',
      'sales',
      'sale_items',
      'suppliers',
    ];

    for (final table in tables) {
      try {
        final ownerIdRow = await db.rawQuery(
          'SELECT ownerId FROM stores LIMIT 1',
        );
        if (ownerIdRow.isEmpty) continue;

        final ownerId = ownerIdRow.first['ownerId'];
        final response = await SyncApi.get('$table?ownerId=$ownerId');

        if (response.isEmpty) continue;

        _logger.i('⬇️ Received ${response.length} rows for $table ($dbName)');

        final batch = db.batch();
        for (final item in response) {
          batch.insert(
            table,
            item,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      } catch (e) {
        _logger.e('❌ Pull failed for $table: $e');
      }
    }

    _logger.i('✅ Cloud pull completed for all databases');
  }

  // =========================================================
  // ✅ 6. HELPER: Mark row as synced
  // =========================================================
  Future<void> _markRowSynced(Database db, String table, dynamic id) async {
    try {
      await db.update(
        table,
        {'is_synced': 1, 'last_updated': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.w('⚠️ Failed to mark $table row $id as synced: $e');
    }
  }

  // =========================================================
  // ✅ 7. HELPER: Find all DBs
  // =========================================================
  Future<List<File>> _getAllDatabases() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final ownersDir = Directory(
      join(documentsDir.path, 'Pos_Desktop', 'owners'),
    );

    if (!ownersDir.existsSync()) return [];

    final dbFiles = <File>[];

    for (final entity in ownersDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.db')) {
        dbFiles.add(entity);
        _logger.i('👤 Found master DB: ${entity.path}');
      }
    }

    return dbFiles;
  }

  // =========================================================
  // ✅ 8. HELPER: Check network
  // =========================================================
  Future<bool> _isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // =========================================================
  // 🧹 Stop auto sync
  // =========================================================
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _isAutoSyncing = false;
    _logger.i('🛑 Auto sync stopped');
  }
}

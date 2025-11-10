import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:logger/logger.dart';

class SyncService {
  // 🔹 Sirf is liye banaya hai taake DatabaseHelper ka constructor chale
  // aur sqfliteFfiInit + databaseFactory set ho jaye.

  final _logger = Logger();

  // ✅ Initial full sync (push local data that’s not synced yet)
  Future<void> performInitialSyncForExistingData() async {
    _logger.i("🚀 Starting initial full sync (local → server)");

    try {
      await _pushUnsynced();
      _logger.i("✅ Initial sync completed successfully for all databases");
    } catch (e) {
      _logger.e("❌ Initial sync failed: $e");
    }
  }

  // 🔄 Auto Sync starter — runs periodically or on connectivity changes
  void startAutoSync() {
    _logger.i("🔁 Auto sync service started");

    // Connectivity listener
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _logger.i("🌐 Network available — running sync");
        syncAllData();
      } else {
        _logger.w("⚠️ Offline — sync paused");
      }
    });

    // Periodic background sync every 10 minutes
    Timer.periodic(const Duration(minutes: 10), (timer) async {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity != ConnectivityResult.none) {
        _logger.i("🕓 Periodic sync triggered");
        await syncAllData();
      }
    });
  }

  // 🔁 Combined sync: push + pull for all offline DBs (master + stores)
  Future<void> syncAllData() async {
    _logger.i("🔁 Sync cycle started (push + pull)");
    await _pushUnsynced();
    await _pullUpdates();
    _logger.i("✅ Sync cycle finished");
  }

  // 🔼 Push unsynced local data to server (for ALL owner/master/store DBs)
  Future<void> _pushUnsynced() async {
    try {
      final databases = await _getAllDatabases();
      if (databases.isEmpty) {
        _logger.w("⚠️ No databases found for sync!");
        return;
      }

      for (final dbFile in databases) {
        final dbPath = dbFile.path;
        final dbName = basename(dbPath);
        _logger.i("⬆️ Pushing unsynced data for DB: $dbName");

        // NOTE: yahan se jo DB open hoga, usko hum close nahi kar rahe
        // taake app ke dusre parts me 'database_closed' error na aaye.
        final db = await databaseFactoryFfi.openDatabase(dbPath);

        // 🧩 Table mapping per DB type (ab system DB nahi hai)
        List<String> tables;
        if (dbName == 'master.db') {
          // owner-level DB → sirf stores table sync hogi
          tables = ['stores'];
        } else {
          // store DBs → categories, products, sales, etc.
          tables = [
            'brands',
            'categories',
            'customers',
            'expenses',
            'products',
            'sales',
            'sale_items',
            'suppliers',
            // 'sync_metadata', // 🔹 local-only, server pe bhejne ki zarurat nahi
          ];
        }

        for (final table in tables) {
          try {
            final unsyncedRows = await db.query(table, where: 'is_synced = 0');
            if (unsyncedRows.isEmpty) continue;

            _logger.i(
              "📤 Syncing ${unsyncedRows.length} from $table ($dbName)",
            );

            for (final row in unsyncedRows) {
              try {
                // 🧹 Local-only fields hatao (server ko nahi bhejne)
                final payload = Map<String, dynamic>.from(row);
                payload.remove('is_synced'); // ✅ ye online nahi chahiye
                payload.remove('last_updated');

                await SyncApi.post("sync/$table", payload);

                // ✅ local row ko synced mark karo
                final updatedCount = await db.update(
                  table,
                  {'is_synced': 1},
                  where: 'id = ?',
                  whereArgs: [row['id']],
                );

                // 🪣 Debug print to verify update
                _logger.i(
                  "🟩 Update result for $table id=${row['id']}: $updatedCount",
                );
                final checkRow = await db.query(
                  table,
                  where: 'id = ?',
                  whereArgs: [row['id']],
                );
                _logger.i("🔍 After update: ${checkRow.first}");

                _logger.i("✅ Synced $table → row ${row['id']} from $dbName");
              } catch (e) {
                _logger.e("❌ Failed to sync $table record ${row['id']}: $e");
              }
            }
          } catch (e) {
            _logger.w("⚠️ Table missing or invalid in $dbName: $table ($e)");
          }
        }

        // ❌ IMPORTANT:
        // yahan 'await db.close();' NAHIN karna,
        // warna agar kahi aur same path se DB open ho to
        // 'database_closed' aa sakta hai.
      }

      // 🔻 pehle yahan pos_system.db pe WAL checkpoint laga rahe the
      // ab system DB hi nahi hai, is liye ye call hata di:
      //
      // await (await DatabaseHelper().database).rawQuery(
      //   'PRAGMA wal_checkpoint(FULL)',
      // );

      _logger.i("✅ Local push completed for all databases");
    } catch (e) {
      _logger.e("❌ Push sync error: $e");
    }
  }

  // 🔽 Pull server updates to local (for all owner/master/store DBs)
  Future<void> _pullUpdates() async {
    try {
      final databases = await _getAllDatabases();
      if (databases.isEmpty) {
        _logger.w("⚠️ No databases found for pull sync!");
        return;
      }

      for (final dbFile in databases) {
        final dbPath = dbFile.path;
        final dbName = basename(dbPath);
        _logger.i("⬇️ Pulling updates for DB: $dbName");

        final db = await databaseFactoryFfi.openDatabase(dbPath);

        List<String> tables;
        if (dbName == 'master.db') {
          tables = ['stores'];
        } else {
          tables = [
            // 'sync_metadata', // 🔹 isko bhi online se pull nahi karna
          ];
        }

        for (final table in tables) {
          try {
            final remoteData = await SyncApi.get("sync/$table");
            if (remoteData.isEmpty) continue;

            _logger.i(
              "⬇️ Received ${remoteData.length} rows for $table ($dbName)",
            );

            for (final row in remoteData) {
              await db.insert(
                table,
                row,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          } catch (e) {
            _logger.w("⚠️ Pull failed for $table in $dbName: $e");
          }
        }

        // yahan bhi db ko close nahi kar rahe, same reason
        // await db.close();
      }

      _logger.i("✅ Cloud pull completed for all databases");
    } catch (e) {
      _logger.e("❌ Pull sync error: $e");
    }
  }

  // 🗂️ Helper → Get all existing .db files from Pos_Desktop/owners/...
  Future<List<File>> _getAllDatabases() async {
    final List<File> dbFiles = [];
    final appDir = await getApplicationDocumentsDirectory();
    final posDesktopDir = Directory(join(appDir.path, 'Pos_Desktop'));

    if (!await posDesktopDir.exists()) {
      _logger.w("⚠️ Pos_Desktop folder not found: ${posDesktopDir.path}");
      return [];
    }

    // ❌ Pehle yahan system DB add kar rahe the:
    // final systemDbPath = join(posDesktopDir.path, 'pos_system.db');
    // Ab system DB use hi nahi ho raha, is liye ye block hata diya.

    // ✅ Owner-level databases (master.db) + store DBs
    final ownersDir = Directory(join(posDesktopDir.path, 'owners'));
    if (await ownersDir.exists()) {
      final ownerFolders = ownersDir.listSync().whereType<Directory>();
      for (final ownerFolder in ownerFolders) {
        // 1) master.db
        final masterPath = join(ownerFolder.path, 'master.db');
        if (File(masterPath).existsSync()) {
          _logger.i("👤 Found master DB: $masterPath");
          dbFiles.add(File(masterPath));
        }

        // 2) each store DB
        final storesDir = Directory(join(ownerFolder.path, 'stores'));
        if (await storesDir.exists()) {
          final storeFiles = storesDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.db'))
              .toList();

          for (final f in storeFiles) {
            _logger.i("🏪 Found store DB: ${f.path}");
            dbFiles.add(f);
          }
        }
      }
    }

    _logger.i("📦 Total DB files found for sync: ${dbFiles.length}");
    return dbFiles;
  }
}

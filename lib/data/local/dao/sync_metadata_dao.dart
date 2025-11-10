import 'package:logger/logger.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/domain/entities/store/sync_metadata_entity.dart';

class SyncMetadataDao {
  final Logger _logger = Logger();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// ✅ Fetch current sync metadata for the given store DB.
  Future<SyncMetadataEntity?> getMetadata(int storeId) async {
    try {
      final db = await _dbHelper.openStoreDB(0, 'unknown', storeId, 'store');
      final result = await db.query('sync_metadata', limit: 1);

      if (result.isEmpty) {
        _logger.i('🕒 No sync metadata found for store $storeId');
        return null;
      }

      final map = result.first;
      return SyncMetadataEntity(
        id: map['id'] as int?,
        lastPushAt: map['last_push_at'] != null
            ? DateTime.tryParse(map['last_push_at'] as String)
            : null,
        lastPullAt: map['last_pull_at'] != null
            ? DateTime.tryParse(map['last_pull_at'] as String)
            : null,
      );
    } catch (e) {
      _logger.e('❌ Error fetching sync metadata: $e');
      return null;
    }
  }

  /// ✅ Initialize metadata row if missing
  Future<void> ensureMetadataExists(int storeId) async {
    final db = await _dbHelper.openStoreDB(0, 'unknown', storeId, 'store');
    final result = await db.query('sync_metadata', limit: 1);
    if (result.isEmpty) {
      await db.insert('sync_metadata', {
        'last_push_at': null,
        'last_pull_at': null,
      });
      _logger.i('🆕 Created initial sync_metadata for store $storeId');
    }
  }

  /// 🔼 Update the last push time
  Future<void> updateLastPush(int storeId, DateTime time) async {
    try {
      final db = await _dbHelper.openStoreDB(0, 'unknown', storeId, 'store');
      await ensureMetadataExists(storeId);
      await db.update('sync_metadata', {
        'last_push_at': time.toIso8601String(),
      });
      _logger.i('📤 Updated last push at: $time');
    } catch (e) {
      _logger.e('❌ Error updating last push time: $e');
    }
  }

  /// 🔽 Update the last pull time
  Future<void> updateLastPull(int storeId, DateTime time) async {
    try {
      final db = await _dbHelper.openStoreDB(0, 'unknown', storeId, 'store');
      await ensureMetadataExists(storeId);
      await db.update('sync_metadata', {
        'last_pull_at': time.toIso8601String(),
      });
      _logger.i('📥 Updated last pull at: $time');
    } catch (e) {
      _logger.e('❌ Error updating last pull time: $e');
    }
  }

  /// 🔄 Clear all metadata (e.g., for manual reset)
  Future<void> clearMetadata(int storeId) async {
    try {
      final db = await _dbHelper.openStoreDB(0, 'unknown', storeId, 'store');
      await db.delete('sync_metadata');
      _logger.w('🗑️ Cleared sync metadata for store $storeId');
    } catch (e) {
      _logger.e('❌ Error clearing sync metadata: $e');
    }
  }
}

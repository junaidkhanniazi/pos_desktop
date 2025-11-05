import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/sale_model.dart';
import 'package:pos_desktop/data/models/sale_item_model.dart';

class SaleDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 🔹 CREATE SALE WITH ITEMS
  Future<int> createSaleWithItems({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required double total,
    required String paymentMethod,
    required List<SaleItemModel> items,
  }) async {
    final db = await _dbHelper.openStoreDB(
      ownerId,
      ownerName,
      storeId,
      storeName,
    );

    try {
      await db.execute('BEGIN TRANSACTION');

      // Insert sale
      final saleId = await db.insert('sales', {
        'total': total,
        'payment_method': paymentMethod,
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
      });

      // Insert sale items
      for (final item in items) {
        await db.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
          'total': item.total,
          'is_synced': 0,
          'last_updated': DateTime.now().toIso8601String(),
        });

        // Update product stock
        final product = await db.query(
          'products',
          where: 'id = ?',
          whereArgs: [item.productId],
          limit: 1,
        );

        if (product.isNotEmpty) {
          final currentStock = product.first['quantity'] as int;
          final newStock = currentStock - item.quantity;
          await db.update(
            'products',
            {'quantity': newStock},
            where: 'id = ?',
            whereArgs: [item.productId],
          );
        }
      }

      await db.execute('COMMIT');
      await db.close();
      return saleId;
    } catch (e) {
      await db.execute('ROLLBACK');
      await db.close();
      print('❌ ERROR creating sale: $e');
      rethrow;
    }
  }

  // 🔹 GET ALL SALES
  Future<List<SaleModel>> getSales({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    int? limit,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query(
        'sales',
        orderBy: 'created_at DESC',
        limit: limit,
      );
      await db.close();
      return data.map((e) => SaleModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting sales: $e');
      rethrow;
    }
  }

  // 🔹 GET SALE ITEMS
  Future<List<SaleItemModel>> getSaleItems({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required int saleId,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );
      final data = await db.query(
        'sale_items',
        where: 'sale_id = ?',
        whereArgs: [saleId],
      );
      await db.close();
      return data.map((e) => SaleItemModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ ERROR getting sale items: $e');
      rethrow;
    }
  }

  // 🔹 GET SALES SUMMARY
  Future<Map<String, dynamic>> getSalesSummary({
    required int storeId,
    required String ownerName,
    required int ownerId,
    required String storeName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await _dbHelper.openStoreDB(
        ownerId,
        ownerName,
        storeId,
        storeName,
      );

      final totalSalesResult = await db.rawQuery(
        '''
        SELECT COUNT(*) as count, COALESCE(SUM(total), 0) as total 
        FROM sales 
        WHERE date(created_at) BETWEEN date(?) AND date(?)
      ''',
        [startDate.toIso8601String(), endDate.toIso8601String()],
      );

      final paymentMethodsResult = await db.rawQuery(
        '''
        SELECT payment_method, COUNT(*) as count, COALESCE(SUM(total), 0) as total 
        FROM sales 
        WHERE date(created_at) BETWEEN date(?) AND date(?)
        GROUP BY payment_method
      ''',
        [startDate.toIso8601String(), endDate.toIso8601String()],
      );

      await db.close();

      return {
        'total_sales': totalSalesResult.first['total'] ?? 0,
        'sales_count': totalSalesResult.first['count'] ?? 0,
        'payment_methods': paymentMethodsResult,
      };
    } catch (e) {
      print('❌ ERROR getting sales summary: $e');
      rethrow;
    }
  }
}

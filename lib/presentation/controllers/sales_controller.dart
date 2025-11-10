import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/domain/entities/store/sale_entity.dart';
import 'package:pos_desktop/domain/entities/store/sale_item_entity.dart';
import 'package:pos_desktop/domain/usecases/sale_usecase.dart';

class SaleController extends GetxController {
  final SaleUseCase _useCase = Get.find<SaleUseCase>();
  final Logger _logger = Logger();

  final sales = <SaleEntity>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // Simple in-memory cart for POS
  final cartItems = <SaleItemEntity>[].obs;
  final cartTotal = 0.0.obs;

  int? _storeId;

  Future<void> init(int storeId) async {
    _storeId = storeId;
    await loadSales();
  }

  Future<void> loadSales() async {
    if (_storeId == null) return;
    try {
      isLoading.value = true;
      sales.value = await _useCase.getAll(_storeId!);
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;
      _logger.e('❌ loadSales error: $e');
      Get.snackbar('Error', failure.message);
    } finally {
      isLoading.value = false;
    }
  }

  void removeFromCart(SaleItemEntity item) {
    cartItems.remove(item);
    _recalculateTotal();
  }

  void clearCart() {
    cartItems.clear();
    cartTotal.value = 0;
  }

  void _recalculateTotal() {
    cartTotal.value = cartItems.fold<double>(0, (sum, i) => sum + (i.total));
  }
}

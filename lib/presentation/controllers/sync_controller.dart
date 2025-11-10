import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/domain/entities/store/sync_metadata_entity.dart';
import 'package:pos_desktop/domain/usecases/sync_usecase.dart';

class SyncController extends GetxController {
  final SyncUseCase _useCase = Get.find<SyncUseCase>();
  final Logger _logger = Logger();

  final isSyncing = false.obs;
  final lastMetadata = Rxn<SyncMetadataEntity>();
  final errorMessage = RxnString();

  int? _storeId;

  void setStore(int storeId) {
    _storeId = storeId;
    refreshMetadata();
  }

  Future<void> refreshMetadata() async {
    if (_storeId == null) return;
    try {
      lastMetadata.value = await _useCase.getMetadata(_storeId!);
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;
      _logger.e('❌ refreshMetadata error: $e');
    }
  }

  Future<void> syncNow() async {
    if (_storeId == null) {
      Get.snackbar('Sync Error', 'Store not selected');
      return;
    }

    try {
      isSyncing.value = true;
      await _useCase.pushLocalChanges(_storeId!);
      await _useCase.pullRemoteChanges(_storeId!);
      await refreshMetadata();
      Get.snackbar('Sync Complete', 'Data synchronized successfully');
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;
      _logger.e('❌ syncNow error: $e');
      Get.snackbar('Sync Error', failure.message);
    } finally {
      isSyncing.value = false;
    }
  }
}

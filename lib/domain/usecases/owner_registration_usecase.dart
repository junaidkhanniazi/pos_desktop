import 'package:logger/logger.dart';
import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';

class OwnerRegistrationUseCase {
  final Logger _logger = Logger();

  Future<void> submitFullRegistration(Map<String, dynamic> payload) async {
    try {
      await SyncApi.post("auth/register", payload);
      _logger.i("✅ Full registration submitted");
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      _logger.e("❌ Registration failed: ${failure.message}");
      throw failure;
    }
  }
}

import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:pos_desktop/core/errors/exception_handler.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/domain/usecases/auth_usecase.dart';

class AuthController extends GetxController {
  final AuthUseCase _authUseCase = Get.find<AuthUseCase>();
  final AuthStorageHelper _authStorage = AuthStorageHelper();
  final Logger _logger = Logger();

  final email = ''.obs;
  final password = ''.obs;
  final activationCode = ''.obs;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final currentRole = Rxn<AuthRole>();

  void setEmail(String value) => email.value = value.trim();
  void setPassword(String value) => password.value = value.trim();
  void setActivationCode(String value) => activationCode.value = value.trim();

  Future<AuthRole?> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Email and password are required');
      return null;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final role = await _authUseCase.login(email.value, password.value);

      if (role == null) {
        errorMessage.value = 'Invalid credentials';
        Get.snackbar('Login Failed', 'Invalid email or password');
        return null;
      }

      currentRole.value = role;

      // await _authStorage.saveLogin(role: role, email: email.value);

      _logger.i('✅ Logged in as ${role.name}');
      Get.snackbar('Login Successful', 'Welcome, ${role.name}');

      return role;
    } catch (e) {
      final failure = ExceptionHandler.handle(e);
      errorMessage.value = failure.message;

      _logger.e('❌ Login error: $e');

      if (failure.message.contains('subscription')) {
        Get.snackbar('Subscription Inactive', failure.message);
      } else {
        Get.snackbar('Login Error', failure.message);
      }

      return null;
    }
  }

  Future<void> logout() async {
    await _authStorage.logout();
    currentRole.value = null;
    email.value = '';
    password.value = '';
    activationCode.value = '';
    Get.snackbar('Logged out', 'You have been logged out successfully');
  }
}

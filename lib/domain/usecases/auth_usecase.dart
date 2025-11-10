import 'package:pos_desktop/domain/entities/auth_role.dart';
import 'package:pos_desktop/domain/repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository _repository;
  AuthUseCase(this._repository);

  Future<AuthRole?> login(String email, String password) {
    return _repository.loginAny(email, password);
  }
}

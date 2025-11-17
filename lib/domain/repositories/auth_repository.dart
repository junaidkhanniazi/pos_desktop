import 'package:pos_desktop/domain/entities/auth_role.dart';

abstract class AuthRepository {
  Future<AuthRole?> loginAny(String email, String password);
}

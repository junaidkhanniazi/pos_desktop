import 'package:pos_desktop/domain/entities/auth_role.dart';

abstract class AuthRepository {
  Future<AuthRole?> loginOwner(String email, String password);

  Future<AuthRole?> loginAny(String email, String password);
}

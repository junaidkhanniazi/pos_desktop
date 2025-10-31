import 'package:pos_desktop/domain/entities/auth_role.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final AuthRole? role;

  const LoginState({this.isLoading = false, this.errorMessage, this.role});

  LoginState copyWith({bool? isLoading, String? errorMessage, AuthRole? role}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      role: role ?? this.role,
    );
  }

  factory LoginState.initial() => const LoginState();
}

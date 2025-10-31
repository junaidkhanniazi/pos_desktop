import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/state_management/controllers/login_controller.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';
import 'package:pos_desktop/presentation/widgets/app_loader.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = LoginController();
  bool _isLoading = false;

  Future<void> _onLogin() async {
    setState(() => _isLoading = true);
    await _controller.login(context);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ clean up controller resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "POS Login",
                      style: AppText.h1.copyWith(color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Login as Super Admin, Owner or Staff",
                      style: AppText.small.copyWith(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Use controller's text fields directly
                    AppInput(
                      controller: _controller.emailCtrl,
                      hint: "Email",
                      type: InputType.email,
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      controller: _controller.passCtrl,
                      hint: "Password",
                      obscureText: true,
                    ),

                    const SizedBox(height: 24),
                    AppButton(
                      label: _isLoading ? "Logging in..." : "Login",
                      icon: Icons.login,
                      isDisabled: _isLoading,
                      onPressed: _isLoading ? null : _onLogin,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an owner account?",
                          style: AppText.small.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.ownerSignup,
                          ),
                          child: Text(
                            "Sign Up",
                            style: AppText.small.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Loader overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const AppLoader(message: "Authenticating..."),
            ),
        ],
      ),
    );
  }
}

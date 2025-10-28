import 'package:flutter/material.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import '../../data/local/dao/super_admin_dao.dart';
import '../../data/local/dao/owner_dao.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _superAdminDao = SuperAdminDao();
  final _ownerDao = OwnerDao();
  bool _isLoading = false;

  // Role detection - simple logic based on email or database check
  Future<String?> _detectUserRole(String email, String password) async {
    // First try Super Admin login
    final superAdmin = await _superAdminDao.login(email, password);
    if (superAdmin != null) {
      return 'super_admin';
    }

    // Then try Owner login (without activation code first to check if owner exists)
    final owner = await _ownerDao.getOwnerByCredentials(email, password);
    if (owner != null) {
      return 'owner';
    }

    return null; // No user found
  }

  Future<void> _login() async {
    // 🔹 Real-time validation
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      AppToast.show(
        context,
        message: "Email and Password cannot be empty",
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = emailCtrl.text.trim();
      final password = passCtrl.text.trim();

      // Detect user role
      final userRole = await _detectUserRole(email, password);

      if (!mounted) return;

      if (userRole == 'super_admin') {
        // Super Admin login
        AppToast.show(
          context,
          message: "Super Admin login successful!",
          type: ToastType.success,
        );
        Navigator.pushReplacementNamed(context, AppRoutes.superAdminDashboard);
      } else if (userRole == 'owner') {
        // Owner login - show activation code popup
        _showActivationCodeDialog(email, password);
      } else {
        AppToast.show(
          context,
          message: "Invalid email or password",
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: "Something went wrong: $e",
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showActivationCodeDialog(String email, String password) {
    final activationCodeCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Activation Code Required", style: AppText.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please enter your activation code to login as Owner.",
              style: AppText.body.copyWith(color: AppColors.textMedium),
            ),
            const SizedBox(height: 16),
            AppInput(
              controller: activationCodeCtrl,
              hint: "Enter Activation Code",
              type: InputType.text,
            ),
          ],
        ),
        actions: [
          AppButton(
            label: "Cancel",
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          AppButton(
            label: "Verify & Login",
            onPressed: () async {
              await _verifyOwnerLogin(
                email,
                password,
                activationCodeCtrl.text.trim(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOwnerLogin(
    String email,
    String password,
    String activationCode,
  ) async {
    if (activationCode.isEmpty) {
      AppToast.show(
        context,
        message: "Please enter activation code",
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    Navigator.pop(context); // Close the dialog

    try {
      final owner = await _ownerDao.getOwnerByCredentials(
        email,
        password,
        activationCode: activationCode,
      );

      if (!mounted) return;

      if (owner != null) {
        AppToast.show(
          context,
          message: "Owner login successful!",
          type: ToastType.success,
        );
        Navigator.pushReplacementNamed(context, AppRoutes.ownerDashboard);
      } else {
        AppToast.show(
          context,
          message: "Invalid activation code",
          type: ToastType.error,
        );
        // Show activation code dialog again
        _showActivationCodeDialog(email, password);
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: "Login failed: $e",
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
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
                  "Login as Super Admin or Owner",
                  style: AppText.small.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: 20),
                AppInput(
                  controller: emailCtrl,
                  hint: "Email",
                  type: InputType.email,
                ),
                const SizedBox(height: 14),
                AppInput(
                  controller: passCtrl,
                  hint: "Password",
                  obscureText: true,
                  type: InputType.text,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: _isLoading ? "Logging in..." : "Login",
                  icon: Icons.login,
                  isDisabled: _isLoading,
                  onPressed: _isLoading ? null : _login,
                ),
                const SizedBox(height: 16),
                // Signup option for owners
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an owner account?",
                      style: AppText.small.copyWith(color: AppColors.textLight),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.ownerSignup);
                      },
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
    );
  }
}

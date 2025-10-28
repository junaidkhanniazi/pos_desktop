import 'package:flutter/material.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';
import '../../data/models/owner_model.dart';
import '../../data/local/dao/owner_dao.dart';
import '../../core/errors/failure.dart';

class OwnerSignupScreen extends StatefulWidget {
  const OwnerSignupScreen({super.key});

  @override
  State<OwnerSignupScreen> createState() => _OwnerSignupScreenState();
}

class _OwnerSignupScreenState extends State<OwnerSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _shopName = TextEditingController();
  final _ownerName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _contact = TextEditingController();

  bool _isLoading = false;
  final _ownerDao = OwnerDao();

  @override
  void dispose() {
    _shopName.dispose();
    _ownerName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _contact.dispose();
    super.dispose();
  }

  void _onSignup() async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure password and confirm password match
    if (_password.text != _confirmPassword.text) {
      AppToast.show(
        context,
        message: 'Passwords do not match',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    final owner = OwnerModel(
      shopName: _shopName.text.trim(),
      ownerName: _ownerName.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      contact: _contact.text.trim(),
      // No activationCode - will be generated when super admin approves
      status: 'pending', // Explicitly set to pending
      isActive: false, // Explicitly set to inactive
    );

    try {
      // Insert new owner into the database
      await _ownerDao.insertOwner(owner);
      AppToast.show(
        context,
        message:
            'Registration submitted successfully! Wait for admin approval.',
        type: ToastType.success,
      );

      // Redirect to login
      Navigator.pop(context);
    } on Failure catch (e) {
      // ✅ Now catching your custom Failure types
      AppToast.show(
        context,
        message: e.message, // User-friendly error message
        type: ToastType.error,
      );
    } catch (e) {
      // Fallback for any unexpected errors
      AppToast.show(
        context,
        message: 'An unexpected error occurred. Please try again.',
        type: ToastType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: size.width * 0.35,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Create Your Store', style: AppText.h1),
                const SizedBox(height: 6),
                Text(
                  'Register as an owner to start managing your POS system',
                  style: AppText.small,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Shop Name
                AppInput(
                  controller: _shopName,
                  hint: 'Shop Name',
                  icon: Icons.storefront,
                ),
                const SizedBox(height: 16),

                // Owner Name
                AppInput(
                  controller: _ownerName,
                  hint: 'Owner Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),

                // Email
                AppInput(
                  controller: _email,
                  hint: 'Email Address',
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),

                // Password
                AppInput(
                  controller: _password,
                  hint: 'Password',
                  obscureText: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                AppInput(
                  controller: _confirmPassword,
                  hint: 'Confirm Password',
                  obscureText: true,
                  icon: Icons.lock_outline,
                ),
                const SizedBox(height: 16),

                // Contact
                AppInput(
                  controller: _contact,
                  hint: 'Contact Number',
                  icon: Icons.phone,
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : AppButton(
                        label: 'Create My Store',
                        width: double.infinity,
                        onPressed: _onSignup,
                      ),

                const SizedBox(height: 16),

                // Already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: AppText.small),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        "Login",
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

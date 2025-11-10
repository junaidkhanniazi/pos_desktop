// import 'package:flutter/material.dart';
// import 'package:pos_desktop/core/routes/app_routes.dart';
// import 'package:pos_desktop/core/theme/app_colors.dart';
// import 'package:pos_desktop/core/theme/app_text_styles.dart';
// import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
// import 'package:pos_desktop/data/repositories_impl/owner_repository_impl.dart';
// import 'package:pos_desktop/presentation/widgets/app_button.dart';
// import 'package:pos_desktop/presentation/widgets/app_input.dart';

// class OwnerSignupScreen extends StatefulWidget {
//   const OwnerSignupScreen({super.key});

//   @override
//   State<OwnerSignupScreen> createState() => _OwnerSignupScreenState();
// }

// class _OwnerSignupScreenState extends State<OwnerSignupScreen> {
//   late final OwnerSignupController controller;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     controller = OwnerSignupController(OwnerRepositoryImpl());
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Center(
//         child: Container(
//           width: size.width * 0.35,
//           padding: const EdgeInsets.all(32),
//           decoration: BoxDecoration(
//             color: AppColors.surface,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.shadow,
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Form(
//             key: controller.formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text('Create Your Store', style: AppText.h1),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Register as an owner to start managing your POS system',
//                   style: AppText.small,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),

//                 // Shop Name
//                 AppInput(
//                   controller: controller.shopName,
//                   hint: 'Shop Name',
//                   icon: Icons.storefront,
//                   validator: controller.validateShopName,
//                 ),
//                 const SizedBox(height: 16),

//                 // Owner Name
//                 AppInput(
//                   controller: controller.ownerName,
//                   hint: 'Owner Name',
//                   icon: Icons.person,
//                   validator: controller.validateOwnerName,
//                 ),
//                 const SizedBox(height: 16),

//                 // Email
//                 AppInput(
//                   controller: controller.email,
//                   hint: 'Email Address',
//                   icon: Icons.email,
//                   type: InputType.email,
//                   validator: controller.validateEmail,
//                 ),
//                 const SizedBox(height: 16),

//                 // Password
//                 AppInput(
//                   controller: controller.password,
//                   hint: 'Password',
//                   obscureText: true,
//                   icon: Icons.lock,
//                   validator: controller.validatePassword,
//                 ),
//                 const SizedBox(height: 16),

//                 // Confirm Password
//                 AppInput(
//                   controller: controller.confirmPassword,
//                   hint: 'Confirm Password',
//                   obscureText: true,
//                   icon: Icons.lock_outline,
//                   validator: controller.validateConfirmPassword,
//                 ),
//                 const SizedBox(height: 16),

//                 // Contact
//                 AppInput(
//                   controller: controller.contact,
//                   hint: 'Contact Number',
//                   icon: Icons.phone,
//                   type: InputType.phone,
//                   validator: controller.validateContact,
//                   maxLength: 11,
//                 ),
//                 const SizedBox(height: 24),

//                 _isLoading
//                     ? const CircularProgressIndicator(color: AppColors.primary)
//                     : AppButton(
//                         label: 'Create My Store',
//                         width: double.infinity,
//                         onPressed: () async {
//                           if (!controller.formKey.currentState!.validate())
//                             return;

//                           setState(() => _isLoading = true);

//                           // 🔹 Perform online signup
//                           final formData = await controller.signup(context);

//                           setState(() => _isLoading = false);

//                           if (formData == null) return;

//                           // ✅ Save temporarily for next step (plan selection)
//                           await AuthStorageHelper.saveTempOwnerData(formData);

//                           controller.clearForm();

//                           if (context.mounted) {
//                             Navigator.pushNamed(
//                               context,
//                               AppRoutes.subscriptionPlans,
//                             );
//                           }
//                         },
//                       ),

//                 const SizedBox(height: 16),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text("Already have an account?", style: AppText.small),
//                     const SizedBox(width: 6),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamed(context, AppRoutes.login);
//                       },
//                       child: Text(
//                         "Login",
//                         style: AppText.small.copyWith(
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pos_desktop/core/theme/app_colors.dart';
// import 'package:pos_desktop/core/theme/app_text_styles.dart';
// import 'package:pos_desktop/core/utils/toast_helper.dart';
// import 'package:pos_desktop/domain/entities/online/subscription_entity.dart';
// import 'package:pos_desktop/presentation/controllers/owner_controller.dart';
// import 'package:pos_desktop/presentation/widgets/app_loader.dart';
// import 'package:pos_desktop/presentation/widgets/app_button.dart';
// import 'package:path/path.dart' as path;

// class OwnerRequestsScreen extends StatelessWidget {
//   OwnerRequestsScreen({super.key});

//   final OwnerController controller = Get.put(OwnerController());
//   final

//   void _showReceiptPreview(BuildContext context, String imagePath) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: const EdgeInsets.all(24),
//         child: Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: AppColors.surface,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadow.withOpacity(0.3),
//                     blurRadius: 20,
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "Payment Receipt",
//                     style: AppText.h2.copyWith(color: AppColors.textDark),
//                   ),
//                   const SizedBox(height: 16),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.network(
//                       "http://localhost:5000/uploads/${path.basename(imagePath)}",
//                       fit: BoxFit.contain,
//                       width: 600,
//                       height: 400,
//                       errorBuilder: (_, __, ___) => Container(
//                         height: 300,
//                         alignment: Alignment.center,
//                         color: AppColors.background,
//                         child: Text(
//                           "Receipt not found",
//                           style: AppText.body.copyWith(
//                             color: AppColors.textLight,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   AppButton(
//                     label: "Close",
//                     width: 180,
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildSubscriptionDetails(OwnerEntity owner) {
//   //   return Container(
//   //     width: double.infinity,
//   //     padding: const EdgeInsets.all(12),
//   //     decoration: BoxDecoration(
//   //       color: AppColors.primary.withOpacity(0.05),
//   //       borderRadius: BorderRadius.circular(8),
//   //     ),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Text(
//   //           "Subscription: ${owner.subscriptionPlan ?? 'N/A'}",
//   //           style: AppText.body.copyWith(fontWeight: FontWeight.w600),
//   //         ),
//   //         if (owner.subscriptionAmount != null)
//   //           Text(
//   //             "Amount: Rs. ${owner.subscriptionAmount}",
//   //             style: AppText.small,
//   //           ),
//   //         if (owner.paymentDate != null)
//   //           Text("Paid on: ${owner.paymentDate}", style: AppText.small),
//   //       ],
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Owner Requests",
//             style: AppText.h1.copyWith(color: AppColors.textDark),
//           ),
//           const SizedBox(height: 24),
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value) {
//                 return const AppLoader(message: "Loading owner requests...");
//               }

//               if (controller.pendingOwners.isEmpty) {
//                 return Center(
//                   child: Text(
//                     "No pending owner requests",
//                     style: AppText.body.copyWith(color: AppColors.textLight),
//                   ),
//                 );
//               }

//               return SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: DataTable(
//                   headingRowColor: WidgetStateProperty.all(
//                     AppColors.background,
//                   ),
//                   headingTextStyle: AppText.body.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textDark,
//                   ),
//                   columns: const [
//                     DataColumn(label: Text("Name")),
//                     DataColumn(label: Text("Email")),
//                     DataColumn(label: Text("Store")),
//                     DataColumn(label: Text("Subscription")),
//                     DataColumn(label: Text("Receipt")),
//                     DataColumn(label: Text("Status")),
//                     DataColumn(label: Text("Actions")),
//                   ],
//                   rows: controller.pendingOwners.map((owner) {
//                     return DataRow(
//                       cells: [
//                         DataCell(Text(owner.ownerName, style: AppText.body)),
//                         DataCell(Text(owner.email, style: AppText.body)),
//                         DataCell(Text(owner.shopName, style: AppText.body)),
//                         DataCell(
//                           FutureBuilder<SubscriptionEntity?>(
//                             future: controller.loadSubscriptionsForOwner(
//                               owner.id,
//                             ),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return Text("Loading...", style: AppText.small);
//                               }
//                               final subscription = snapshot.data;
//                               return Text(
//                                 subscription?.subscriptionPlanName ?? "No Plan",
//                                 style: AppText.small,
//                               );
//                             },
//                           ),
//                         ),
//                         DataCell(
//                           FutureBuilder<SubscriptionEntity?>(
//                             future: controller.getOwnerSubscription(owner.id),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return Text("Loading...", style: AppText.small);
//                               }
//                               final subscription = snapshot.data;
//                               final hasReceipt =
//                                   subscription?.receiptImage != null &&
//                                   subscription!.receiptImage!.isNotEmpty;

//                               return hasReceipt
//                                   ? TextButton.icon(
//                                       icon: Icon(
//                                         Icons.visibility,
//                                         color: AppColors.primary,
//                                       ),
//                                       label: Text(
//                                         "View",
//                                         style: TextStyle(
//                                           color: AppColors.primary,
//                                         ),
//                                       ),
//                                       onPressed: () => _showReceiptPreview(
//                                         context,
//                                         subscription.receiptImage!,
//                                       ),
//                                     )
//                                   : Text(
//                                       "N/A",
//                                       style: AppText.small.copyWith(
//                                         color: AppColors.textLight,
//                                       ),
//                                     );
//                             },
//                           ),
//                         ),
//                         DataCell(
//                           Text(
//                             owner.status,
//                             style: AppText.small.copyWith(
//                               color: AppColors.textDark,
//                             ),
//                           ),
//                         ),
//                         DataCell(
//                           Row(
//                             children: [
//                               if (owner.status == "pending") ...[
//                                 IconButton(
//                                   icon: const Icon(
//                                     Icons.check_circle,
//                                     color: AppColors.success,
//                                   ),
//                                   tooltip: "Approve",
//                                   onPressed: () async {
//                                     // 🔹 Step 1: Show confirmation dialog BEFORE approving
//                                     final confirm = await showDialog<bool>(
//                                       context: context,
//                                       builder: (_) => AlertDialog(
//                                         backgroundColor: AppColors.surface,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             16,
//                                           ),
//                                         ),
//                                         title: Row(
//                                           children: [
//                                             const Icon(
//                                               Icons.help_outline_rounded,
//                                               color: AppColors.primary,
//                                               size: 28,
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Text(
//                                               "Confirm Approval",
//                                               style: AppText.h2,
//                                             ),
//                                           ],
//                                         ),
//                                         content: Text(
//                                           "Are you sure you want to approve '${owner.ownerName}'?\n\n"
//                                           "This will activate their subscription and store access.",
//                                           style: AppText.body.copyWith(
//                                             color: AppColors.textMedium,
//                                           ),
//                                         ),
//                                         actions: [
//                                           AppButton(
//                                             label: "Cancel",
//                                             onPressed: () =>
//                                                 Navigator.pop(context, false),
//                                           ),
//                                           AppButton(
//                                             label: "Approve",
//                                             onPressed: () =>
//                                                 Navigator.pop(context, true),
//                                           ),
//                                         ],
//                                       ),
//                                     );

//                                     // 🔹 Step 2: If admin cancels, do nothing
//                                     if (confirm != true) return;

//                                     // 🔹 Step 3: Show toast while approving
//                                     AppToast.show(
//                                       context,
//                                       message:
//                                           "Approving owner, please wait...",
//                                       type: ToastType.info,
//                                     );

//                                     // 🔹 Step 4: Call controller method
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(
//                                     Icons.cancel_rounded,
//                                     color: AppColors.error,
//                                   ),
//                                   tooltip: "Reject",
//                                   onPressed: () async {
//                                     await controller.rejectOwner(owner.id);
//                                     AppToast.show(
//                                       context,
//                                       message: "Owner rejected successfully.",
//                                       type: ToastType.success,
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }

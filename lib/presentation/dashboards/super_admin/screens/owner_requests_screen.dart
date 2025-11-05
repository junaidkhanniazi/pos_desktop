import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/domain/entities/subscription_entity.dart';
import 'package:pos_desktop/presentation/state_management/controllers/owner_requests_controller.dart';
import 'package:pos_desktop/presentation/widgets/app_loader.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/domain/entities/owner_entity.dart';

class OwnerRequestsScreen extends StatelessWidget {
  OwnerRequestsScreen({super.key});

  final OwnerRequestsController controller = Get.put(OwnerRequestsController());

  // ✅ Activation Code Dialog
  void _showApprovalDialog(
    BuildContext context,
    String name,
    String? planName,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.verified_rounded,
              color: AppColors.success,
              size: 30,
            ),
            const SizedBox(width: 8),
            Text("Owner Approved", style: AppText.h2),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Owner '$name' has been approved successfully!",
              style: AppText.body.copyWith(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    "Subscription Activated",
                    style: AppText.h2.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Plan: ${planName ?? 'N/A'}",
                    style: AppText.small.copyWith(color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Store access has been enabled for the owner.",
              style: AppText.small.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          AppButton(label: "Close", onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  void _showReceiptPreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Payment Receipt",
                    style: AppText.h2.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                      width: 600,
                      height: 400,
                      errorBuilder: (_, __, ___) => Container(
                        height: 300,
                        alignment: Alignment.center,
                        color: AppColors.background,
                        child: Text(
                          "Receipt not found",
                          style: AppText.body.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: "Close",
                    width: 180,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetails(OwnerEntity owner) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Subscription: ${owner.subscriptionPlan ?? 'N/A'}",
            style: AppText.body.copyWith(fontWeight: FontWeight.w600),
          ),
          if (owner.subscriptionAmount != null)
            Text(
              "Amount: Rs. ${owner.subscriptionAmount}",
              style: AppText.small,
            ),
          if (owner.paymentDate != null)
            Text("Paid on: ${owner.paymentDate}", style: AppText.small),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Owner Requests",
            style: AppText.h1.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoader(message: "Loading owner requests...");
              }

              if (controller.pendingOwners.isEmpty) {
                return Center(
                  child: Text(
                    "No pending owner requests",
                    style: AppText.body.copyWith(color: AppColors.textLight),
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.background,
                  ),
                  headingTextStyle: AppText.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  columns: const [
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Store")),
                    DataColumn(label: Text("Subscription")),
                    DataColumn(label: Text("Receipt")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: controller.pendingOwners.map((owner) {
                    return DataRow(
                      cells: [
                        DataCell(Text(owner.name, style: AppText.body)),
                        DataCell(Text(owner.email, style: AppText.body)),
                        DataCell(Text(owner.storeName, style: AppText.body)),
                        DataCell(
                          FutureBuilder<SubscriptionEntity?>(
                            future: controller.getOwnerSubscription(owner.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading...", style: AppText.small);
                              }
                              final subscription = snapshot.data;
                              return Text(
                                subscription?.subscriptionPlanName ?? "No Plan",
                                style: AppText.small,
                              );
                            },
                          ),
                        ),
                        DataCell(
                          FutureBuilder<SubscriptionEntity?>(
                            future: controller.getOwnerSubscription(owner.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading...", style: AppText.small);
                              }
                              final subscription = snapshot.data;
                              final hasReceipt =
                                  subscription?.receiptImage != null &&
                                  subscription!.receiptImage!.isNotEmpty;

                              return hasReceipt
                                  ? TextButton.icon(
                                      icon: Icon(
                                        Icons.visibility,
                                        color: AppColors.primary,
                                      ),
                                      label: Text(
                                        "View",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      onPressed: () => _showReceiptPreview(
                                        context,
                                        subscription!.receiptImage!,
                                      ),
                                    )
                                  : Text(
                                      "N/A",
                                      style: AppText.small.copyWith(
                                        color: AppColors.textLight,
                                      ),
                                    );
                            },
                          ),
                        ),
                        DataCell(
                          Text(
                            owner.status.name,
                            style: AppText.small.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              if (owner.status == OwnerStatus.pending) ...[
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                  ),
                                  tooltip: "Approve",
                                  onPressed: () async {
                                    // 🔹 Step 1: Show confirmation dialog BEFORE approving
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor: AppColors.surface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            const Icon(
                                              Icons.help_outline_rounded,
                                              color: AppColors.primary,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Confirm Approval",
                                              style: AppText.h2,
                                            ),
                                          ],
                                        ),
                                        content: Text(
                                          "Are you sure you want to approve '${owner.name}'?\n\n"
                                          "This will activate their subscription and store access.",
                                          style: AppText.body.copyWith(
                                            color: AppColors.textMedium,
                                          ),
                                        ),
                                        actions: [
                                          AppButton(
                                            label: "Cancel",
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                          ),
                                          AppButton(
                                            label: "Approve",
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                          ),
                                        ],
                                      ),
                                    );

                                    // 🔹 Step 2: If admin cancels, do nothing
                                    if (confirm != true) return;

                                    // 🔹 Step 3: Show toast while approving
                                    AppToast.show(
                                      context,
                                      message:
                                          "Approving owner, please wait...",
                                      type: ToastType.info,
                                    );

                                    // 🔹 Step 4: Call controller method
                                    final updatedOwner = await controller
                                        .approveOwner(owner, context);

                                    // 🔹 Step 5: Handle result
                                    if (updatedOwner != null) {
                                      AppToast.show(
                                        context,
                                        message: "Owner approved successfully!",
                                        type: ToastType.success,
                                      );

                                      // Optional: show final success dialog
                                      // _showApprovalDialog(
                                      //   context,
                                      //   owner.name,
                                      //   owner.subscriptionPlan,
                                      // );

                                      await controller.loadPendingOwners();
                                    } else {
                                      AppToast.show(
                                        context,
                                        message:
                                            "Failed to approve owner. Please try again.",
                                        type: ToastType.error,
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel_rounded,
                                    color: AppColors.error,
                                  ),
                                  tooltip: "Reject",
                                  onPressed: () async {
                                    final success = await controller
                                        .rejectOwner(owner);
                                    if (success) {
                                      AppToast.show(
                                        context,
                                        message: "Owner rejected successfully.",
                                        type: ToastType.success,
                                      );
                                    } else {
                                      AppToast.show(
                                        context,
                                        message: "Failed to reject owner.",
                                        type: ToastType.error,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

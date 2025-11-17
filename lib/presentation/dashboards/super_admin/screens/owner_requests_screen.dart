import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/presentation/controllers/owner_controller.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_loader.dart';

class OwnerRequestsScreen extends StatelessWidget {
  OwnerRequestsScreen({super.key});

  final OwnerController controller = Get.put(OwnerController());

  void _showReceiptPreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
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
              Text("Payment Receipt", style: AppText.h2),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "http://localhost:5000/uploads/${path.basename(imagePath)}",
                  fit: BoxFit.contain,
                  width: 600,
                  height: 400,
                  errorBuilder: (_, __, ___) => Container(
                    height: 300,
                    alignment: Alignment.center,
                    child: Text(
                      "Receipt not found",
                      style: AppText.body.copyWith(color: AppColors.textLight),
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
          Text("Pending Owner Requests", style: AppText.h1),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoader(message: "Loading owner requests...");
              }

              final owners = controller.pendingOwners;
              if (owners.isEmpty) {
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
                    DataColumn(label: Text("Owner Name")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Store")),
                    // DataColumn(label: Text("Subscription")),
                    // DataColumn(label: Text("Receipt")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: owners.map((owner) {
                    return DataRow(
                      cells: [
                        DataCell(Text(owner.ownerName)),
                        DataCell(Text(owner.email)),
                        // ✅ Subscription Plan
                        // DataCell(
                        //   FutureBuilder<SubscriptionEntity?>(
                        //     future: controller.getOwnerSubscription(owner.id),
                        //     builder: (context, snapshot) {
                        //       if (snapshot.connectionState ==
                        //           ConnectionState.waiting) {
                        //         return Text("Loading...", style: AppText.small);
                        //       }
                        //       final subscription = snapshot.data;
                        //       return Text(
                        //         subscription?.subscriptionPlanName ??
                        //             "No Plan Found",
                        //         style: AppText.small,
                        //       );
                        //     },
                        //   ),
                        // ),
                        // // ✅ Receipt Preview
                        // DataCell(
                        //   FutureBuilder<SubscriptionEntity?>(
                        //     future: controller.getOwnerSubscription(owner.id),
                        //     builder: (context, snapshot) {
                        //       if (snapshot.connectionState ==
                        //           ConnectionState.waiting) {
                        //         return Text("Loading...", style: AppText.small);
                        //       }
                        //       final subscription = snapshot.data;
                        //       final hasReceipt =
                        //           subscription?.receiptImage?.isNotEmpty ==
                        //           true;

                        //       if (!hasReceipt) {
                        //         return Text(
                        //           "N/A",
                        //           style: AppText.small.copyWith(
                        //             color: AppColors.textLight,
                        //           ),
                        //         );
                        //       }

                        //       return TextButton.icon(
                        //         icon: Icon(
                        //           Icons.visibility,
                        //           color: AppColors.primary,
                        //         ),
                        //         label: Text(
                        //           "View",
                        //           style: TextStyle(
                        //             color: AppColors.primary,
                        //             fontWeight: FontWeight.w500,
                        //           ),
                        //         ),
                        //         onPressed: () => _showReceiptPreview(
                        //           context,
                        //           subscription!.receiptImage!,
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                        DataCell(Text(owner.status)),
                        // ✅ Actions
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                ),
                                tooltip: "Approve",
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Confirm Approval"),
                                      content: Text(
                                        "Approve ${owner.ownerName}?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Approve"),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm != true) return;
                                  AppToast.show(
                                    context,
                                    message: "Approving...",
                                    type: ToastType.info,
                                  );
                                  await controller.approveOwner(
                                    owner.id.toString(),
                                    30,
                                  );
                                  AppToast.show(
                                    context,
                                    message: "Owner approved successfully.",
                                    type: ToastType.success,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: AppColors.error,
                                ),
                                tooltip: "Reject",
                                onPressed: () async {
                                  await controller.rejectOwner(owner.id);
                                  AppToast.show(
                                    context,
                                    message: "Owner rejected successfully.",
                                    type: ToastType.success,
                                  );
                                },
                              ),
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

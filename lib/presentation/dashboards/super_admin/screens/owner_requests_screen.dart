import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:pos_desktop/data/models/owner_model.dart';

class OwnerRequestsScreen extends StatefulWidget {
  const OwnerRequestsScreen({super.key});

  @override
  State<OwnerRequestsScreen> createState() => _OwnerRequestsScreenState();
}

class _OwnerRequestsScreenState extends State<OwnerRequestsScreen> {
  final OwnerDao _ownerDao = OwnerDao();
  List<OwnerModel> _pendingOwners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingOwners();
  }

  Future<void> _loadPendingOwners() async {
    try {
      setState(() => _isLoading = true);
      final owners = await _ownerDao.getPendingOwners();
      setState(() {
        _pendingOwners = owners;
      });
    } catch (e) {
      AppToast.show(
        context,
        message: 'Failed to load owner requests',
        type: ToastType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _approveOwner(OwnerModel owner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Approve Owner", style: AppText.h2),
        content: Text(
          "Are you sure you want to approve '${owner.ownerName}'?\n\n"
          "This will generate an activation code for them.",
          style: AppText.body.copyWith(color: AppColors.textMedium),
        ),
        actions: [
          AppButton(
            label: "Cancel",
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          AppButton(
            label: "Approve",
            icon: Icons.verified_user,
            onPressed: () async {
              Navigator.pop(context);
              await _processApproval(owner);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processApproval(OwnerModel owner) async {
    try {
      // Activate owner in database - this generates activation code
      await _ownerDao.activateOwner(owner.id!);

      // Reload the list to get updated owner with activation code
      await _loadPendingOwners();

      // Find the updated owner with activation code
      final updatedOwners = await _ownerDao.getAllOwners();
      final updatedOwner = updatedOwners.firstWhere((o) => o.id == owner.id);

      _showActivationDialog(
        updatedOwner.ownerName,
        updatedOwner.activationCode!,
      );

      AppToast.show(
        context,
        message: 'Owner approved successfully!',
        type: ToastType.success,
      );
    } catch (e) {
      AppToast.show(
        context,
        message: 'Failed to approve owner: $e',
        type: ToastType.error,
      );
    }
  }

  void _rejectOwner(OwnerModel owner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Reject Owner", style: AppText.h2),
        content: Text(
          "Are you sure you want to reject '${owner.ownerName}'?",
          style: AppText.body.copyWith(color: AppColors.textMedium),
        ),
        actions: [
          AppButton(
            label: "Cancel",
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          AppButton(
            label: "Reject",
            icon: Icons.close,
            onPressed: () async {
              Navigator.pop(context);
              await _processRejection(owner);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processRejection(OwnerModel owner) async {
    try {
      await _ownerDao.rejectOwner(owner.id!);
      await _loadPendingOwners();

      AppToast.show(
        context,
        message: 'Owner rejected successfully!',
        type: ToastType.success,
      );
    } catch (e) {
      AppToast.show(
        context,
        message: 'Failed to reject owner: $e',
        type: ToastType.error,
      );
    }
  }

  void _showActivationDialog(String name, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Activation Code Generated", style: AppText.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Owner '$name' has been approved successfully!",
              style: AppText.body.copyWith(color: AppColors.textMedium),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Text(
                code,
                style: AppText.h2.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Share this code with the owner to activate their account",
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
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

          // 🧾 Table container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _pendingOwners.isEmpty
                  ? Center(
                      child: Text(
                        "No pending owner requests",
                        style: AppText.body.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
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
                          DataColumn(label: Text("Date")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: _pendingOwners.map((owner) {
                          final status = owner.status;
                          Color badgeColor;
                          String statusText;

                          switch (status) {
                            case "approved":
                              badgeColor = AppColors.success;
                              statusText = "Approved";
                              break;
                            case "rejected":
                              badgeColor = AppColors.error;
                              statusText = "Rejected";
                              break;
                            default:
                              badgeColor = AppColors.warning;
                              statusText = "Pending";
                          }

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(owner.ownerName, style: AppText.body),
                              ),
                              DataCell(Text(owner.email, style: AppText.body)),
                              DataCell(
                                Text(owner.shopName, style: AppText.body),
                              ),
                              DataCell(
                                Text(
                                  _formatDate(owner.createdAt),
                                  style: AppText.small,
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: AppText.small.copyWith(
                                      color: badgeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    if (status == "pending") ...[
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: AppColors.success,
                                        ),
                                        tooltip: "Approve",
                                        onPressed: () => _approveOwner(owner),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.cancel_rounded,
                                          color: AppColors.error,
                                        ),
                                        tooltip: "Reject",
                                        onPressed: () => _rejectOwner(owner),
                                      ),
                                    ],
                                    if (status == "approved" &&
                                        owner.activationCode != null)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.key_rounded,
                                          color: AppColors.primary,
                                        ),
                                        tooltip: "View Code",
                                        onPressed: () => _showActivationDialog(
                                          owner.ownerName,
                                          owner.activationCode!,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

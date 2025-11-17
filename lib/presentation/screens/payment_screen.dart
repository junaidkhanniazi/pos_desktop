import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';
import 'package:pos_desktop/presentation/controllers/owner_onboarding_controller.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_loader.dart';

class PaymentScreen extends StatefulWidget {
  final SubscriptionPlanEntity selectedPlan;

  const PaymentScreen({super.key, required this.selectedPlan});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  File? _receiptImage;
  bool _isSubmitting = false;
  bool _isLoadingData = true;
  Map<String, dynamic>? _tempOwnerData;
  final OwnerOnboardingController controller = Get.find();

  @override
  void initState() {
    super.initState();
    _loadTempData();
  }

  Future<void> _loadTempData() async {
    try {
      _tempOwnerData = await AuthStorageHelper.getTempOwnerData();
      print('📋 Payment screen loaded temp data: $_tempOwnerData');
    } catch (e) {
      print('❌ Error loading temp data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        setState(() => _receiptImage = file);

        // ✅ keep the controller in sync
        controller.receiptImage = file;
      }
    } catch (e) {
      AppToast.show(
        context,
        message: 'Failed to pick file: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> _submitRequest() async {
    await controller.submitFullRegistration(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isSubmitting
          ? const Center(
              child: AppLoader(message: "Submitting your payment..."),
            )
          : Row(
              children: [
                _buildLeftSummary(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildUploadCard(),
                        const SizedBox(height: 32),
                        _buildSubmitSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLeftSummary() {
    if (_isLoadingData) {
      return Container(
        width: 360,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            right: BorderSide(color: AppColors.border.withOpacity(0.2)),
          ),
          boxShadow: [
            BoxShadow(color: AppColors.shadow.withOpacity(0.08), blurRadius: 8),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Loading your information...'),
          ],
        ),
      );
    }

    return Container(
      width: 360,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border.withOpacity(0.2)),
        ),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Summary",
            style: AppText.h2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          _buildPlanCard(),
          const SizedBox(height: 24),
          _infoRow(
            Icons.store_rounded,
            "Store Name",
            _tempOwnerData?['shopName']?.toString() ?? 'Loading...',
          ),
          _infoRow(
            Icons.person_rounded,
            "Owner Name",
            _tempOwnerData?['ownerName']?.toString() ?? 'Loading...',
          ),
          _infoRow(
            Icons.email_rounded,
            "Email",
            _tempOwnerData?['email']?.toString() ?? 'Loading...',
          ),
          _infoRow(
            Icons.phone_rounded,
            "Contact",
            _tempOwnerData?['contact']?.toString() ?? 'Loading...',
          ),
          const Spacer(),
          Divider(color: AppColors.border.withOpacity(0.3)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: AppText.h3.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                "Rs. ${widget.selectedPlan.price.toStringAsFixed(0)}",
                style: AppText.h2.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.1),
          AppColors.primary.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.workspace_premium, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          widget.selectedPlan.name,
          style: AppText.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          "Rs. ${widget.selectedPlan.price.toStringAsFixed(0)} for ${widget.selectedPlan.durationDays} days",
          style: AppText.small.copyWith(color: AppColors.textLight),
        ),
      ],
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.small.copyWith(color: AppColors.textLight),
              ),
              Text(
                value,
                style: AppText.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Upload Payment Receipt", style: AppText.h1),
      const SizedBox(height: 6),
      Text(
        "Please upload your payment receipt to activate your account.",
        style: AppText.body.copyWith(color: AppColors.textLight),
      ),
    ],
  );

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_receiptImage == null)
            Column(
              children: [
                Icon(
                  Icons.cloud_upload_rounded,
                  color: AppColors.textLight,
                  size: 60,
                ),
                const SizedBox(height: 12),
                Text(
                  "Drag & Drop or Click to Upload",
                  style: AppText.h3.copyWith(color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  "Supported formats: JPG, PNG, PDF (max 5MB)",
                  style: AppText.small.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: "Browse File",
                  icon: Icons.upload_rounded,
                  onPressed: _pickFile,
                ),
              ],
            )
          else
            Column(
              children: [
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 200,
                    maxHeight: 400,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _receiptImage!,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Receipt Uploaded Successfully",
                              style: AppText.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _receiptImage!.path.split('/').last,
                              style: AppText.small.copyWith(
                                color: AppColors.textLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppButton(
                        label: "Change",
                        icon: Icons.refresh_rounded,
                        onPressed: _pickFile,
                        isPrimary: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitSection() => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.verified_rounded, color: AppColors.success, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                "Your payment info is secure and encrypted.",
                style: AppText.small.copyWith(color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      AppButton(
        label: "Submit for Approval",
        icon: Icons.send_rounded,
        width: double.infinity,
        onPressed: _receiptImage != null ? _submitRequest : null,
        isDisabled: _receiptImage == null,
      ),
      const SizedBox(height: 10),
      Text(
        "Once verified, your account will be activated within 24 hours.",
        style: AppText.small.copyWith(
          color: AppColors.textLight,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

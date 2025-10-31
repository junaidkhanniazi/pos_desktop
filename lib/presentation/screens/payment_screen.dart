import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/domain/entities/subscription_plan_entity.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_loader.dart';
import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:pos_desktop/domain/entities/owner_entity.dart';
import 'package:pos_desktop/domain/repositories/repositories_impl/owner_repository_impl.dart';

class PaymentScreen extends StatefulWidget {
  final String shopName;
  final String ownerName;
  final String email;
  final String password;
  final String contact; // ✅ CHANGED: from String? to String (required)
  final SubscriptionPlanEntity selectedPlan;

  const PaymentScreen({
    super.key,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.password,
    required this.contact, // ✅ CHANGED: from optional to required
    required this.selectedPlan,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final OwnerDao _ownerDao = OwnerDao();
  File? _receiptImage;
  bool _isSubmitting = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _receiptImage = File(result.files.single.path!);
        });
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
    if (_receiptImage == null) {
      AppToast.show(
        context,
        message: 'Please upload your payment receipt first',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // ✅ Create OwnerEntity with ALL required fields
      final ownerEntity = OwnerEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: widget.ownerName,
        email: widget.email,
        storeName: widget.shopName,
        password: widget.password, // ✅ ADDED: Required field
        contact: widget.contact, // ✅ ADDED: Required field
        superAdminId: null, // ✅ ADDED: Can be null
        status: OwnerStatus.pending,
        createdAt: DateTime.now(),
        activationCode: null, // ✅ ADDED: Can be null
        subscriptionPlan: widget.selectedPlan.name,
        receiptImage: _receiptImage!.path,
        paymentDate: DateTime.now(),
        subscriptionAmount: widget.selectedPlan.price,
        subscriptionStartDate: null, // Will be set when approved
        subscriptionEndDate: null, // Will be set when approved
      );

      final repo = OwnerRepositoryImpl();
      await repo.addOwner(ownerEntity);

      AppToast.show(
        context,
        message: 'Request submitted successfully! Wait for admin approval.',
        type: ToastType.success,
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
    } catch (e) {
      AppToast.show(
        context,
        message: 'Submission failed: $e',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
          _infoRow(Icons.store_rounded, "Store Name", widget.shopName),
          _infoRow(Icons.person_rounded, "Owner Name", widget.ownerName),
          _infoRow(Icons.email_rounded, "Email", widget.email),
          _infoRow(
            Icons.phone_rounded,
            "Contact",
            widget.contact,
          ), // ✅ Now required
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

  Widget _buildPlanCard() {
    return Container(
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
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
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
  }

  Widget _buildHeader() {
    return Column(
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
  }

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
                  constraints: BoxConstraints(minHeight: 200, maxHeight: 400),
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
                      alignment: Alignment.center,
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

  Widget _buildSubmitSection() {
    return Column(
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/presentation/controllers/owner_onboarding_controller.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  final OwnerOnboardingController controller = Get.find();
  SubscriptionPlanEntity? selectedPlan;
  Map<String, dynamic>? tempOwnerData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    tempOwnerData = await AuthStorageHelper.getTempOwnerData();
    await controller.loadPlans();
    setState(() {});
  }

  void _selectPlan(SubscriptionPlanEntity plan) {
    setState(() => selectedPlan = plan);
  }

  void _goToPayment() {
    if (selectedPlan == null) return;
    controller.selectedPlan = selectedPlan;
    Navigator.pushNamed(
      context,
      AppRoutes.payment,
      arguments: {'selectedPlan': selectedPlan},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Choose Your Plan", style: AppText.h2),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final plans = controller.plans;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select a subscription plan for your store",
                style: AppText.body,
              ),
              const SizedBox(height: 32),

              if (tempOwnerData != null) _buildOwnerCard(),

              Expanded(
                child: GridView.builder(
                  itemCount: plans.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final isSelected = selectedPlan?.id == plan.id;

                    return GestureDetector(
                      onTap: () => _selectPlan(plan),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan.name, style: AppText.h2),
                            const SizedBox(height: 8),
                            Text(
                              "Rs. ${plan.price} / ${plan.durationDays} days",
                              style: AppText.body.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: plan.features.length,
                                itemBuilder: (context, i) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        plan.features[i],
                                        style: AppText.small,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AppButton(
                              label: isSelected ? "Selected" : "Select Plan",
                              isPrimary: isSelected,
                              onPressed: () => _selectPlan(plan),
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              AppButton(
                label: "Continue to Payment",
                isDisabled: selectedPlan == null,
                width: double.infinity,
                onPressed: selectedPlan != null ? _goToPayment : null,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOwnerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Store: ${tempOwnerData?['shopName'] ?? 'N/A'}"),
                Text(
                  "Owner: ${tempOwnerData?['ownerName'] ?? 'N/A'}",
                  style: AppText.small.copyWith(color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

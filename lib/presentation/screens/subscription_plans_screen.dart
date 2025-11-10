import 'package:flutter/material.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/data/repositories_impl/owner_repository_impl.dart';
import 'package:pos_desktop/domain/entities/online/subscription_plan_entity.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key}); // ✅ Remove required ownerId

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  bool isLoading = true;
  List<SubscriptionPlanEntity> plans = [];
  SubscriptionPlanEntity? selectedPlan;
  Map<String, dynamic>? tempOwnerData; // ✅ Store temp data here

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // ✅ Load temporary owner data
      tempOwnerData = await AuthStorageHelper.getTempOwnerData();
      print('📋 Loaded temp owner data: $tempOwnerData');

      // ✅ Load subscription plans from API
      final repo = OwnerRepositoryImpl();
      final allPlans = await repo.getSubscriptionPlans();

      setState(() {
        plans = allPlans.map((p) => SubscriptionPlanEntity.fromMap(p)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  void _selectPlan(SubscriptionPlanEntity plan) {
    setState(() => selectedPlan = plan);
  }

  void _goToPayment() {
    if (selectedPlan == null) return;

    // ✅ Only pass the selected plan, owner data comes from temp storage
    Navigator.pushNamed(
      context,
      AppRoutes.payment,
      arguments: {'selectedPlan': selectedPlan!},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Choose Your Plan", style: AppText.h2),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select a subscription plan for your store",
                    style: AppText.body.copyWith(color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Each plan offers unique features tailored to your business size.",
                    style: AppText.small.copyWith(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 32),

                  // Show owner info if available
                  if (tempOwnerData != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Store: ${tempOwnerData!['shopName'] ?? 'N/A'}",
                                  style: AppText.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Owner: ${tempOwnerData!['ownerName'] ?? 'N/A'}",
                                  style: AppText.small.copyWith(
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Grid for plans
                  Expanded(
                    child: GridView.builder(
                      itemCount: plans.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.name,
                                  style: AppText.h2.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Rs. ${plan.price.toStringAsFixed(0)} / ${plan.durationDays} days",
                                  style: AppText.body.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: plan.features.length,
                                    itemBuilder: (context, i) => Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          color: AppColors.success,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            plan.features[i],
                                            style: AppText.small.copyWith(
                                              color: AppColors.textMedium,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AppButton(
                                  label: isSelected
                                      ? "Selected"
                                      : "Select Plan",
                                  width: double.infinity,
                                  isPrimary: isSelected,
                                  onPressed: () => _selectPlan(plan),
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
                    width: double.infinity,
                    isDisabled: selectedPlan == null,
                    onPressed: selectedPlan != null ? _goToPayment : null,
                  ),
                ],
              ),
            ),
    );
  }
}

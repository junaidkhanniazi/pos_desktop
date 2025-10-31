import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_desktop/core/routes/app_routes.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/domain/entities/subscription_plan_entity.dart';
import 'package:pos_desktop/presentation/state_management/controllers/subscription_management_controller.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/local/dao/subscription_plan_dao.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  final String shopName;
  final String ownerName;
  final String email;
  final String password;
  final String contact; // ✅ CHANGED: from String? to String

  const SubscriptionPlansScreen({
    super.key,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.password,
    required this.contact, // ✅ CHANGED: from optional to required
  });

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  late final SubscriptionManagementController controller;
  bool _isControllerInitialized = false;
  SubscriptionPlanEntity? _selectedPlan; // ✅ MOVE TO STATE LEVEL

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final dbHelper = DatabaseHelper();
      final database = await dbHelper.database;
      final subscriptionPlanDao = SubscriptionPlanDao(database);

      // Create controller instance
      controller = SubscriptionManagementController(
        subscriptionPlanDao,
        context,
      );

      // Manually call onInit since we're not using Get.put
      controller.onInit();

      setState(() {
        _isControllerInitialized = true;
      });

      print('✅ Controller initialized successfully');
      print('📊 Plans count: ${controller.plans.length}');
    } catch (e) {
      print('❌ Error initializing controller: $e');
    }
  }

  void _onPlanSelected(SubscriptionPlanEntity plan) {
    setState(() {
      _selectedPlan = plan;
    });
    print('✅ Plan selected: ${plan.name}');
  }

  void _proceedToPayment() {
    if (_selectedPlan == null) {
      print('❌ No plan selected');
      return;
    }

    print('🚀 Proceeding to payment with plan: ${_selectedPlan!.name}');

    Navigator.pushNamed(
      context,
      AppRoutes.payment,
      arguments: {
        'shopName': widget.shopName,
        'ownerName': widget.ownerName,
        'email': widget.email,
        'password': widget.password,
        'contact': widget.contact,
        'selectedPlan': _selectedPlan!,
      },
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
      body: !_isControllerInitialized
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
                    "All plans include 30-day access. Choose the one that fits your business needs.",
                    style: AppText.small.copyWith(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 32),

                  // Expanded grid for plans
                  Expanded(
                    child: Obx(() {
                      print(
                        '🔄 Obx rebuilding, isLoading: ${controller.isLoading.value}',
                      );
                      print(
                        '📦 Plans count in Obx: ${controller.plans.length}',
                      );
                      print('🎯 Selected plan: ${_selectedPlan?.name}');

                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final plans = controller.plans;
                      if (plans.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No subscription plans available",
                                style: AppText.body.copyWith(
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => controller.loadPlans(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        itemCount: plans.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 24,
                              crossAxisSpacing: 24,
                              childAspectRatio: 0.72,
                            ),
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          return _PlanCard(
                            plan: plan,
                            isSelected: _selectedPlan == plan,
                            onSelected: () => _onPlanSelected(plan),
                          );
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                  AppButton(
                    label: "Continue to Payment",
                    width: double.infinity,
                    onPressed: _selectedPlan != null ? _proceedToPayment : null,
                    isDisabled: _selectedPlan == null,
                  ),
                ],
              ),
            ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  final SubscriptionPlanEntity plan;
  final bool isSelected;
  final VoidCallback onSelected;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final isSelected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          print('🎯 Card tapped: ${plan.name}');
          widget.onSelected();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : _hovering
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected || _hovering)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.08),
                  blurRadius: 10,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                plan.name,
                style: AppText.h2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Rs. ${plan.price.toStringAsFixed(0)}",
                style: AppText.h1.copyWith(color: AppColors.primary),
              ),
              Text(
                "per ${plan.durationDays} days",
                style: AppText.small.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: plan.features.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              plan.features[index],
                              style: AppText.small.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: isSelected ? "Selected" : "Select Plan",
                width: double.infinity,
                isPrimary: isSelected,
                onPressed: () {
                  print('🎯 Button pressed: ${plan.name}');
                  widget.onSelected();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

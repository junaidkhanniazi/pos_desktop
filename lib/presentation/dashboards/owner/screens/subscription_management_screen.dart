import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_loader.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';
import 'package:pos_desktop/domain/entities/subscription_plan_entity.dart';
import 'package:pos_desktop/presentation/state_management/controllers/subscription_plan_management_controller.dart';
import 'package:pos_desktop/data/local/dao/subscription_plan_dao.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  late final SubscriptionPlanManagementController _controller;
  bool _isControllerReady = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final db = await DatabaseHelper().database;
    _controller = SubscriptionPlanManagementController(
      dao: SubscriptionPlanDao(db),
      context: context,
    );
    await _controller.loadPlans();
    if (mounted) {
      setState(() => _isControllerReady = true);
    }
  }

  void _addPlan() => _showAddPlanDialog();

  void _showAddPlanDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    final maxStoresController = TextEditingController(text: '1');
    final maxProductsController = TextEditingController(text: '100');
    final maxCategoriesController = TextEditingController(text: '10');
    final featuresController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Create New Plan", style: AppText.h2),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInput(
                  controller: nameController,
                  hint: "Plan Name",
                  icon: Icons.business_center_rounded,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Plan name is required' : null,
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: priceController,
                  hint: "Price (\$)",
                  icon: Icons.attach_money_rounded,
                  type: InputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Price is required';
                    if (double.tryParse(v) == null) return 'Enter valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: durationController,
                  hint: "Duration (days)",
                  icon: Icons.calendar_today_rounded,
                  type: InputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Duration required';
                    if (int.tryParse(v) == null) return 'Enter valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppInput(
                        controller: maxStoresController,
                        hint: "Max Stores",
                        icon: Icons.store_rounded,
                        type: InputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInput(
                        controller: maxProductsController,
                        hint: "Max Products",
                        icon: Icons.inventory_2_rounded,
                        type: InputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: maxCategoriesController,
                  hint: "Max Categories",
                  icon: Icons.category_rounded,
                  type: InputType.number,
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: featuresController,
                  hint: "Features (comma separated)",
                  icon: Icons.featured_play_list_rounded,
                  maxLength: 200,
                ),
              ],
            ),
          ),
        ),
        actions: [
          AppButton(
            label: "Cancel",
            isPrimary: false,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: "Create Plan",
            icon: Icons.add_rounded,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _createNewPlan(
                  name: nameController.text,
                  price: double.parse(priceController.text),
                  durationDays: int.parse(durationController.text),
                  maxStores: int.parse(maxStoresController.text),
                  maxProducts: int.parse(maxProductsController.text),
                  maxCategories: int.parse(maxCategoriesController.text),
                  features: featuresController.text,
                );
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _createNewPlan({
    required String name,
    required double price,
    required int durationDays,
    required int maxStores,
    required int maxProducts,
    required int maxCategories,
    required String features,
  }) {
    final plan = SubscriptionPlanEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      price: price,
      durationDays: durationDays,
      features: _parseFeatures(features),
      maxStores: maxStores,
      maxProducts: maxProducts,
      maxCategories: maxCategories,
    );
    _controller.addPlan(plan);
  }

  List<String> _parseFeatures(String featuresText) {
    if (featuresText.isEmpty) return ['Basic Features'];
    return featuresText
        .split(',')
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toList();
  }

  void _editPlan(SubscriptionPlanEntity plan) {
    _showEditPlanDialog(plan);
  }

  void _showEditPlanDialog(SubscriptionPlanEntity plan) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: plan.name);
    final priceController = TextEditingController(text: plan.price.toString());
    final durationController = TextEditingController(
      text: plan.durationDays.toString(),
    );
    final maxStoresController = TextEditingController(
      text: plan.maxStores.toString(),
    );
    final maxProductsController = TextEditingController(
      text: plan.maxProducts.toString(),
    );
    final maxCategoriesController = TextEditingController(
      text: plan.maxCategories.toString(),
    );
    final featuresController = TextEditingController(
      text: plan.features.join(', '),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Edit Plan", style: AppText.h2),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInput(
                  controller: nameController,
                  hint: "Plan Name",
                  icon: Icons.business_center_rounded,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Plan name is required' : null,
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: priceController,
                  hint: "Price (\$)",
                  icon: Icons.attach_money_rounded,
                  type: InputType.number,
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: durationController,
                  hint: "Duration (days)",
                  icon: Icons.calendar_today_rounded,
                  type: InputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppInput(
                        controller: maxStoresController,
                        hint: "Max Stores",
                        icon: Icons.store_rounded,
                        type: InputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInput(
                        controller: maxProductsController,
                        hint: "Max Products",
                        icon: Icons.inventory_2_rounded,
                        type: InputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: maxCategoriesController,
                  hint: "Max Categories",
                  icon: Icons.category_rounded,
                  type: InputType.number,
                ),
                const SizedBox(height: 16),
                AppInput(
                  controller: featuresController,
                  hint: "Features (comma separated)",
                  icon: Icons.featured_play_list_rounded,
                  maxLength: 200,
                ),
              ],
            ),
          ),
        ),
        actions: [
          AppButton(
            label: "Cancel",
            isPrimary: false,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: "Update",
            icon: Icons.save_rounded,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final updatedPlan = SubscriptionPlanEntity(
                  id: plan.id,
                  name: nameController.text,
                  price: double.parse(priceController.text),
                  durationDays: int.parse(durationController.text),
                  features: _parseFeatures(featuresController.text),
                  maxStores: int.parse(maxStoresController.text),
                  maxProducts: int.parse(maxProductsController.text),
                  maxCategories: int.parse(maxCategoriesController.text),
                );
                _controller.editPlan(updatedPlan);
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _deletePlan(SubscriptionPlanEntity plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Plan", style: AppText.h2),
        content: Text(
          "Are you sure you want to delete '${plan.name}'?",
          style: AppText.body.copyWith(color: AppColors.textMedium),
        ),
        actions: [
          AppButton(
            label: "Cancel",
            isPrimary: false,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          AppButton(
            label: "Delete",
            icon: Icons.delete_rounded,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _controller.deletePlan(plan.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerReady) {
      return const Center(child: AppLoader(message: "Loading..."));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Subscription Plans",
            style: AppText.h1.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: "Add New Plan",
            icon: Icons.add_rounded,
            width: 180,
            onPressed: _addPlan,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const AppLoader(
                  message: "Loading subscription plans...",
                );
              }

              final plans = _controller.plans;
              if (plans.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.subscriptions_rounded,
                        size: 64,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No subscription plans found",
                        style: AppText.body.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Click 'Add New Plan' to create your first plan",
                        style: AppText.small.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.background,
                  ),
                  headingTextStyle: AppText.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  columns: const [
                    DataColumn(label: Text("Plan Name")),
                    DataColumn(label: Text("Duration")),
                    DataColumn(label: Text("Price")),
                    DataColumn(label: Text("Stores")),
                    DataColumn(label: Text("Products")),
                    DataColumn(label: Text("Categories")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: plans.map((plan) {
                    return DataRow(
                      cells: [
                        DataCell(Text(plan.name, style: AppText.body)),
                        DataCell(
                          Text(
                            "${plan.durationDays} days",
                            style: AppText.body,
                          ),
                        ),
                        DataCell(Text("\$${plan.price}", style: AppText.body)),
                        DataCell(
                          Text(plan.maxStores.toString(), style: AppText.body),
                        ),
                        DataCell(
                          Text(
                            plan.maxProducts.toString(),
                            style: AppText.body,
                          ),
                        ),
                        DataCell(
                          Text(
                            plan.maxCategories.toString(),
                            style: AppText.body,
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => _editPlan(plan),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  color: AppColors.error,
                                ),
                                onPressed: () => _deletePlan(plan),
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

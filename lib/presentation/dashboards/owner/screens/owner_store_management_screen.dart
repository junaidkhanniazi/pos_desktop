import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/data/local/dao/store_dao.dart';
import 'package:pos_desktop/data/models/store_model.dart';
import 'package:pos_desktop/data/remote/api/sync_api.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';
import 'package:pos_desktop/presentation/widgets/app_loader.dart';

class OwnerStoreManagementScreen extends StatefulWidget {
  const OwnerStoreManagementScreen({super.key});

  @override
  State<OwnerStoreManagementScreen> createState() =>
      _OwnerStoreManagementScreenState();
}

class _OwnerStoreManagementScreenState
    extends State<OwnerStoreManagementScreen> {
  bool _isLoading = true;
  late StoreDao _storeDao;

  List<StoreModel> _stores = [];
  int _maxStoresAllowed = 0;
  int _ownerId = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      _storeDao = StoreDao();

      final ownerIdStr = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      _ownerId = int.tryParse(ownerIdStr ?? "0") ?? 0;

      await _loadStores();
      await _loadPlanLimitOnline();
    } catch (e) {
      AppToast.show(context, message: "Initialization failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔹 Fetch stores (online + fallback local)
  Future<void> _loadStores() async {
    _stores = await _storeDao.getAllStores(_ownerId);
    if (mounted) setState(() {});
  }

  // 🔹 NEW: Get plan limit directly from server
  Future<void> _loadPlanLimitOnline() async {
    try {
      final response = await SyncApi.getSingle("owners/$_ownerId/plan-limit");

      if (response != null && response["maxStores"] != null) {
        _maxStoresAllowed = int.tryParse(response["maxStores"].toString()) ?? 0;
      } else {
        _maxStoresAllowed = 0;
      }

      print("📊 Owner Plan Limit → $_maxStoresAllowed stores allowed");
    } catch (e) {
      _maxStoresAllowed = 0;
      print("⚠️ Could not fetch plan limit (offline fallback): $e");
    }
  }

  Future<void> _addNewStoreDialog() async {
    final formKey = GlobalKey<FormState>();
    final storeNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Create New Store", style: AppText.h2),
        content: Form(
          key: formKey,
          child: AppInput(
            controller: storeNameController,
            hint: "Enter store name",
            icon: Icons.store_rounded,
            validator: (v) =>
                v == null || v.isEmpty ? 'Store name is required' : null,
          ),
        ),
        actions: [
          AppButton(
            label: "Cancel",
            isPrimary: false,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: "Create",
            icon: Icons.add_rounded,
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final currentStores = await _storeDao.getAllStores(_ownerId);

              // 🧠 Only apply plan limit if it’s > 0
              if (_maxStoresAllowed > 0 &&
                  currentStores.length >= _maxStoresAllowed) {
                AppToast.show(
                  context,
                  message:
                      "You've reached your store limit ($_maxStoresAllowed stores). Please upgrade your plan.",
                  type: ToastType.warning,
                );
                Navigator.pop(ctx); // close the add store dialog
                await _showUpgradePlanDialog();
                return;
              }

              final randomId = Random().nextInt(900000) + 100000;

              final newStore = StoreModel(
                id: randomId,
                ownerId: _ownerId,
                storeName: storeNameController.text.trim(),
                folderPath:
                    "C:/pos_data/owner_$_ownerId/${storeNameController.text.trim()}",
                dbPath:
                    "C:/pos_data/owner_$_ownerId/${storeNameController.text.trim()}/store.db",
                isSynced: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              await _storeDao.insertStore(newStore);

              Navigator.pop(ctx);
              await _loadStores();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(StoreModel store) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Store", style: AppText.h2),
        content: Text(
          "Are you sure you want to delete '${store.storeName}'?",
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
      await _storeDao.deleteStore(store.id);
      await _loadStores();
    }
  }

  Future<void> _showUpgradePlanDialog() async {
    try {
      // AppToast.show(context, message: "Fetching available plans...");
      final plans = await SyncApi.get("subscription-plans");

      if (plans == null || plans.isEmpty) {
        AppToast.show(
          context,
          message: "No plans available.",
          type: ToastType.error,
        );
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Upgrade Plan", style: AppText.h2),
          content: SizedBox(
            width: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      plan["name"],
                      style: AppText.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "💰 \$${plan["price"]} — ${plan["maxStores"]} stores",
                      style: AppText.small,
                    ),
                    trailing: AppButton(
                      label: "Upgrade",
                      icon: Icons.upgrade_rounded,
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _upgradePlan(plan);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    } catch (e) {
      AppToast.show(
        context,
        message: "Failed to load plans: $e",
        type: ToastType.error,
      );
    }
  }

  Future<void> _upgradePlan(Map<String, dynamic> plan) async {
    try {
      // 🧾 Ask for receipt image
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        AppToast.show(
          context,
          message: "Please upload a receipt image to proceed.",
        );
        return;
      }

      final filePath = result.files.single.path!;
      AppToast.show(context, message: "Uploading receipt...");

      // 🔄 Upload new subscription (multipart)
      final response = await SyncApi.postMultipart(
        "owners/subscriptions",
        {
          "ownerId": _ownerId.toString(),
          "subscriptionPlan": plan["name"],
          "subscriptionAmount": plan["price"].toString(),
        },
        fileField: "receipt_image",
        filePath: filePath,
      );

      if (response != null && response["success"] == true) {
        AppToast.show(context, message: "✅ Plan upgraded successfully!");
        await _loadPlanLimitOnline();
      } else {
        AppToast.show(
          context,
          message: "Upgrade failed. Please try again.",
          type: ToastType.error,
        );
      }
    } catch (e) {
      AppToast.show(
        context,
        message: "Error upgrading plan: $e",
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: AppLoader(message: "Loading stores..."));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("My Stores", style: AppText.h1),
              Row(
                children: [
                  Text(
                    "Plan Limit: $_maxStoresAllowed stores",
                    style: AppText.small.copyWith(color: AppColors.textMedium),
                  ),
                  const SizedBox(width: 16),
                  AppButton(
                    label: "Add New Store",
                    icon: Icons.add_rounded,
                    onPressed: _addNewStoreDialog,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Table
          Expanded(
            child: _stores.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_rounded,
                          size: 60,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No stores created yet",
                          style: AppText.body.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Click 'Add New Store' to create one.",
                          style: AppText.small.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
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
                        DataColumn(label: Text("Store Name")),
                        DataColumn(label: Text("Created")),
                        DataColumn(label: Text("Path")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: _stores.map((store) {
                        return DataRow(
                          cells: [
                            DataCell(Text(store.storeName)),
                            DataCell(
                              Text(
                                store.createdAt
                                        ?.toLocal()
                                        .toString()
                                        .split(' ')
                                        .first ??
                                    'N/A',
                              ),
                            ),
                            DataCell(Text(store.folderPath!)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_rounded,
                                      color: AppColors.error,
                                    ),
                                    onPressed: () => _confirmDelete(store),
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
        ],
      ),
    );
  }
}

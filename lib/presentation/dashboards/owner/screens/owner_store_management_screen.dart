// lib/presentation/dashboards/owner/screens/owner_store_management_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/data/local/dao/store_dao.dart';
import 'package:pos_desktop/data/local/dao/subscription_plan_dao.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/store_model.dart';
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
  late SubscriptionPlanDao _planDao;

  List<StoreModel> _stores = [];
  int _maxStoresAllowed = 0;
  String _ownerName = "";
  int _ownerId = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final db = await DatabaseHelper().database;
      _storeDao = StoreDao();
      _planDao = SubscriptionPlanDao(db);

      final ownerIdStr = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      _ownerId = int.tryParse(ownerIdStr ?? "0") ?? 0;
      _ownerName = email?.split('@').first ?? "owner";

      await _loadStores();
      await _loadPlanLimit();
    } catch (e) {
      AppToast.show(context, message: "Initialization failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStores() async {
    _stores = await _storeDao.getAllStores(_ownerId, _ownerName);
    if (mounted) setState(() {});
  }

  Future<void> _loadPlanLimit() async {
    final limits = await _planDao.getOwnerPlanLimits(_ownerId);
    _maxStoresAllowed = limits?['maxStores'] ?? 0;
    print("📊 Owner Plan Limit → $_maxStoresAllowed stores allowed");
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

              final currentStores = await _storeDao.getAllStores(
                _ownerId,
                _ownerName,
              );
              if (currentStores.length >= _maxStoresAllowed) {
                AppToast.show(
                  context,
                  message:
                      "You’ve reached your store limit ($_maxStoresAllowed stores).",
                  type: ToastType.error,
                );
                return;
              }

              await _storeDao.createStore(
                context: context,
                ownerId: _ownerId,
                ownerName: _ownerName,
                storeName: storeNameController.text.trim(),
              );
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
      await _storeDao.deleteStore(
        context: context,
        ownerId: _ownerId,
        ownerName: _ownerName,
        storeId: store.id!,
      );
      await _loadStores();
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
                            DataCell(Text(store.folderPath)),
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

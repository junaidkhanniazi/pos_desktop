// lib/presentation/dashboards/owner/componets/owner_topbar.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/data/local/dao/store_dao.dart';
import 'package:pos_desktop/data/local/database/database_helper.dart';
import 'package:pos_desktop/data/models/store_model.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';

class OwnerTopBar extends StatefulWidget {
  final VoidCallback? onStoreSwitched;
  const OwnerTopBar({super.key, this.onStoreSwitched});

  @override
  State<OwnerTopBar> createState() => _OwnerTopBarState();
}

class _OwnerTopBarState extends State<OwnerTopBar> {
  final StoreDao _storeDao = StoreDao();
  List<StoreModel> _stores = [];
  StoreModel? _currentStore;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    try {
      final ownerId = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      final ownerName = email?.split('@').first ?? "owner";

      if (ownerId != null) {
        _stores = await _storeDao.getAllStores(int.parse(ownerId), ownerName);
        await _loadCurrentStore();
      }
    } catch (e) {
      _showErrorToast('Failed to load stores');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCurrentStore() async {
    final currentStoreId = await AuthStorageHelper.getCurrentStoreId();

    if (currentStoreId != null && _stores.isNotEmpty) {
      final store = _stores.firstWhere(
        (store) => store.id == currentStoreId,
        orElse: () => _stores.first,
      );
      if (mounted) {
        setState(() => _currentStore = store);
      }
    } else if (_stores.isNotEmpty) {
      // Set first store as default if none selected
      if (mounted) {
        setState(() => _currentStore = _stores.first);
      }
      await AuthStorageHelper.setCurrentStore(_stores.first);
    }
  }

  Future<void> _switchStore(StoreModel newStore) async {
    try {
      final previousStore = _currentStore;
      await AuthStorageHelper.setCurrentStore(newStore);
      if (mounted) {
        setState(() => _currentStore = newStore);
      }

      print("\n" + "=" * 50);
      print("🔄 STORE SWITCHING DEBUG INFO");
      print("=" * 50);
      print("📋 SWITCH DETAILS:");
      print(
        "   FROM: ${previousStore?.storeName ?? 'None'} (ID: ${previousStore?.id ?? 'N/A'})",
      );
      print("   TO: ${newStore.storeName} (ID: ${newStore.id})");
      print("   ──────────────────────────────────────");

      final ownerId = await AuthStorageHelper.getOwnerId();
      final email = await AuthStorageHelper.getEmail();
      final ownerName = email?.split('@').first ?? "owner";

      if (ownerId != null) {
        print("📁 LOADING CATEGORIES FROM DATABASE...");

        // 🔹 Pass correct store name for loading categories from the correct DB
        final categories = await _storeDao.getStoreCategories(
          newStore.id!,
          ownerName,
          int.parse(ownerId),
          newStore.storeName, // Ensure passing correct store name here
        );

        print("✅ CATEGORIES IN ${newStore.storeName.toUpperCase()}:");
        if (categories.isEmpty) {
          print("   🚫 No categories found in database");
        } else {
          for (final category in categories) {
            print(
              "   🏷️  ID: ${category['id']} | Name: ${category['name']} | Desc: ${category['description']}",
            );
          }
          print("   📊 TOTAL CATEGORIES: ${categories.length}");
        }

        final dbPath = await DatabaseHelper().getStoreDbPath(
          ownerName,
          newStore.storeName, // pass store name here to get correct path
        );
        print("   💾 Database Path: $dbPath");
      }

      print("=" * 50);
      print("✅ STORE SWITCH COMPLETED SUCCESSFULLY");
      print("=" * 50 + "\n");

      // 🔥 ADD THIS LINE - Call the callback to notify parent
      widget.onStoreSwitched?.call();

      _showSuccessToast('Switched to ${newStore.storeName}');
    } catch (e) {
      print("\n❌ STORE SWITCHING ERROR: $e");
      _showErrorToast('Failed to switch store');
    }
  }

  void _showStoreDropdown() {
    if (_stores.isEmpty) {
      _showInfoToast('No stores available');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildStoreBottomSheet(),
    );
  }

  Widget _buildStoreBottomSheet() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.store,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Stores",
                        style: AppText.h2.copyWith(color: AppColors.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${_stores.length} stores available",
                        style: AppText.small.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _stores.length.toString(),
                    style: AppText.small.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Stores List
          Expanded(
            child: _stores.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _stores.length,
                    itemBuilder: (context, index) {
                      final store = _stores[index];
                      final isCurrent = _currentStore?.id == store.id;
                      return _buildStoreListItem(store, isCurrent);
                    },
                  ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Footer
          _buildManageStoresButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                LucideIcons.store,
                size: 40,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No Stores Found",
              style: AppText.h3.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              "Create your first store to get started",
              style: AppText.body.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreListItem(StoreModel store, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withOpacity(0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            if (!isCurrent) {
              _switchStore(store);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Store Icon with Status
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.store,
                    size: 20,
                    color: isCurrent ? Colors.white : AppColors.textMedium,
                  ),
                ),
                const SizedBox(width: 16),

                // Store Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.storeName,
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Created: ${_formatDate(store.createdAt)}",
                        style: AppText.small.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        store.folderPath.split('/').last,
                        style: AppText.small.copyWith(
                          color: AppColors.textLight,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Current Store Badge or Chevron
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.check,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Active",
                          style: AppText.small.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageStoresButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            // Navigate to store management screen
            // Navigator.push(context, MaterialPageRoute(builder: (_) => StoreManagementScreen()));
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.settings, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  "Manage All Stores",
                  style: AppText.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSuccessToast(String message) {
    AppToast.show(context, message: message, type: ToastType.success);
  }

  void _showErrorToast(String message) {
    AppToast.show(context, message: message, type: ToastType.error);
  }

  void _showInfoToast(String message) {
    AppToast.show(context, message: message, type: ToastType.info);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70, // Restored original height
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8, // Restored original blur
            offset: const Offset(0, 2),
          ),
        ],
        // Removed the bottom border to restore original design
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 Title / Logo - Restored original design
          Row(
            children: [
              Icon(
                LucideIcons.layoutDashboard,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                _currentStore != null
                    ? "${_currentStore!.storeName} Dashboard"
                    : "Dashboard",
                style: AppText.h3.copyWith(color: AppColors.textDark),
              ),
            ],
          ),

          // 🔹 Right side - Restored original design
          Row(
            children: [
              // 🔍 Search (optional)
              SizedBox(
                width: 220,
                child: AppInput(
                  controller: TextEditingController(),
                  hint: "Search...",
                  icon: LucideIcons.search,
                ),
              ),
              const SizedBox(width: 16),

              // 🔔 Notification icon
              _buildIconButton(
                icon: LucideIcons.bell,
                tooltip: "Notifications",
                onPressed: () {},
              ),
              const SizedBox(width: 8),

              // ⚙️ Settings icon
              _buildIconButton(
                icon: LucideIcons.settings,
                tooltip: "Settings",
                onPressed: () {},
              ),
              const SizedBox(width: 20),

              // 👤 User avatar with store switcher - Restored original design
              InkWell(
                onTap: _stores.isNotEmpty ? _showStoreDropdown : null,
                borderRadius: BorderRadius.circular(25),
                child: Row(
                  children: [
                    // Store indicator if multiple stores
                    if (_stores.length > 1) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.store,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _currentStore?.storeName ?? "Select Store",
                              style: AppText.small.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // User avatar
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Owner",
                      style: AppText.body.copyWith(color: AppColors.textDark),
                    ),
                    if (_stores.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Icon(
                        LucideIcons.chevronDown,
                        size: 16,
                        color: AppColors.textMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable themed icon button - Restored original design
  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: AppText.small.copyWith(color: Colors.white),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppColors.textMedium, size: 20),
        ),
      ),
    );
  }
}

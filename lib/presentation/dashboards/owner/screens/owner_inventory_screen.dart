import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';
import 'package:pos_desktop/presentation/state_management/controllers/category_controller.dart';

class OwnerInventoryScreen extends StatefulWidget {
  const OwnerInventoryScreen({super.key});

  @override
  State<OwnerInventoryScreen> createState() => _OwnerInventoryScreenState();
}

class _OwnerInventoryScreenState extends State<OwnerInventoryScreen> {
  final CategoryController _categoryController = Get.find<CategoryController>();

  final List<String> _brands = ["All Brands"];
  int selectedCategoryIndex = 0;
  String? selectedBrand;

  // Dummy products data
  final Map<String, List<Map<String, dynamic>>> _dummyProducts = {
    "All Brands": [
      {
        "name": "Sample Product 1",
        "stock": 12,
        "price": 150.0,
        "status": "In Stock",
        "history": <Map<String, dynamic>>[],
      },
      {
        "name": "Sample Product 2",
        "stock": 5,
        "price": 130.0,
        "status": "Low Stock",
        "history": <Map<String, dynamic>>[],
      },
      {
        "name": "Sample Product 3",
        "stock": 0,
        "price": 200.0,
        "status": "Out of Stock",
        "history": <Map<String, dynamic>>[],
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    selectedBrand = _brands.first;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await _categoryController.loadCategories();
  }

  // 🔹 ADDED - Listen to controller changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-refresh when controller data changes
    _categoryController.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _categoryController.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {
        // Force UI update when controller data changes
      });
    }
  }

  // Using controller data
  List<String> get categories => _categoryController.categoryNames;

  String get selectedCategory =>
      _categoryController.getCategoryName(selectedCategoryIndex);

  List<Map<String, dynamic>> get productsForSelection =>
      _dummyProducts[selectedBrand] ?? [];

  void _onCategoryTap(int index) {
    if (index >= categories.length) return;
    setState(() => selectedCategoryIndex = index);
  }

  void _onBrandChanged(String? value) {
    if (value == null) return;
    setState(() => selectedBrand = value);
  }

  // ---------- Inventory Actions ----------
  void updateStock(int index, int change) {
    setState(() {
      final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
      final product = productsForSelection[index];
      final oldStock = product['stock'] as int;
      final newStock = (oldStock + change).clamp(0, 9999);

      product['stock'] = newStock;
      product['status'] = newStock == 0
          ? "Out of Stock"
          : newStock < 10
          ? "Low Stock"
          : "In Stock";

      (product['history'] as List<Map<String, dynamic>>).insert(0, {
        "date": now,
        "change": change,
        "newStock": newStock,
      });
    });
  }

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Product", style: AppText.h2),
        content: Text(
          "Are you sure you want to delete '${productsForSelection[index]['name']}'?",
          style: AppText.body.copyWith(color: AppColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: AppText.body),
          ),
          AppButton(
            label: "Delete",
            icon: Icons.delete_outline,
            onPressed: () {
              setState(() {
                _dummyProducts[selectedBrand]!.removeAt(index);
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(int index) {
    final product = productsForSelection[index];
    final history = (product['history'] as List<Map<String, dynamic>>).toList();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Stock History — ${product['name']}",
                  style: AppText.h2.copyWith(color: AppColors.textDark),
                ),
                const SizedBox(height: 16),
                history.isEmpty
                    ? Text(
                        "No stock changes recorded yet.",
                        style: AppText.body,
                      )
                    : SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            AppColors.background,
                          ),
                          headingTextStyle: AppText.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          columns: const [
                            DataColumn(label: Text("Date")),
                            DataColumn(label: Text("Change")),
                            DataColumn(label: Text("New Stock")),
                          ],
                          rows: history.map((e) {
                            final c = (e['change'] as int);
                            final clr = c > 0
                                ? AppColors.success
                                : c < 0
                                ? AppColors.error
                                : AppColors.textMedium;
                            return DataRow(
                              cells: [
                                DataCell(Text(e['date'], style: AppText.small)),
                                DataCell(
                                  Text(
                                    "${c > 0 ? '+' : ''}$c",
                                    style: AppText.body.copyWith(
                                      color: clr,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text("${e['newStock']}", style: AppText.body),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: "Close",
                    isPrimary: false,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddOrEditDialog({int? editIndex}) {
    final isNew = editIndex == null;
    final product = isNew ? null : productsForSelection[editIndex];

    final nameCtrl = TextEditingController(text: product?['name'] ?? "");
    final priceCtrl = TextEditingController(
      text: product?['price']?.toString() ?? "",
    );
    final stockCtrl = TextEditingController(
      text: product?['stock']?.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isNew ? "Add Product" : "Edit Product",
                  style: AppText.h2.copyWith(color: AppColors.textDark),
                ),
                const SizedBox(height: 18),
                // Category + Brand info
                Row(
                  children: [
                    Expanded(child: _pillInfo("Category", selectedCategory)),
                    const SizedBox(width: 10),
                    Expanded(child: _pillInfo("Brand", selectedBrand ?? "-")),
                  ],
                ),
                const SizedBox(height: 14),
                AppInput(
                  controller: nameCtrl,
                  hint: "Product Name",
                  icon: Icons.inventory_2_outlined,
                ),
                const SizedBox(height: 12),
                AppInput(
                  controller: priceCtrl,
                  hint: "Price (\$)",
                  icon: Icons.attach_money,
                ),
                const SizedBox(height: 12),
                AppInput(
                  controller: stockCtrl,
                  hint: "Initial Stock",
                  icon: Icons.numbers_outlined,
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      label: "Cancel",
                      isPrimary: false,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    AppButton(
                      label: isNew ? "Add" : "Save",
                      icon: isNew ? Icons.add : Icons.check,
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final price =
                            double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                        final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;

                        if (name.isEmpty) return;

                        final status = stock == 0
                            ? "Out of Stock"
                            : stock < 10
                            ? "Low Stock"
                            : "In Stock";

                        setState(() {
                          if (isNew) {
                            _dummyProducts[selectedBrand]!.add({
                              "name": name,
                              "price": price,
                              "stock": stock,
                              "status": status,
                              "history": <Map<String, dynamic>>[],
                            });
                          } else {
                            _dummyProducts[selectedBrand]![editIndex] = {
                              "name": name,
                              "price": price,
                              "stock": stock,
                              "status": status,
                              "history": product!['history'],
                            };
                          }
                        });

                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pillInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: AppText.small.copyWith(color: AppColors.textMedium),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: AppText.body.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    // guard in case brand disappeared
    if (selectedBrand == null || !_brands.contains(selectedBrand)) {
      selectedBrand = _brands.first;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP: Title + Brand filter + Add
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Inventory",
                style: AppText.h1.copyWith(color: AppColors.textDark),
              ),

              Row(
                children: [
                  // Brand dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBrand,
                        onChanged: _onBrandChanged,
                        items: _brands
                            .map(
                              (b) => DropdownMenuItem(
                                value: b,
                                child: Text(
                                  b,
                                  style: AppText.body.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: "Add Product",
                    icon: Icons.add,
                    onPressed: () => _showAddOrEditDialog(),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // CATEGORY TABS (pills) - NOW USING CONTROLLER DATA
          Obx(
            () => _categoryController.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _categoryController.categories.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "No categories found. Add categories first.",
                          style: AppText.body.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 46,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) {
                        final isSelected = i == selectedCategoryIndex;
                        final category = _categoryController.categories[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => _onCategoryTap(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.shadow.withOpacity(
                                          0.12,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              category.name,
                              style: isSelected
                                  ? AppText.button
                                  : AppText.body.copyWith(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemCount: categories.length,
                    ),
                  ),
          ),

          const SizedBox(height: 18),

          // TABLE - KEEPING DUMMY PRODUCTS
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    AppColors.background,
                  ),
                  headingTextStyle: AppText.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  dataRowMinHeight: 58,
                  dataRowMaxHeight: 58,
                  columns: const [
                    DataColumn(label: Text("Product Name")),
                    DataColumn(label: Text("Stock")),
                    DataColumn(label: Text("Price")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: List.generate(productsForSelection.length, (index) {
                    final p = productsForSelection[index];
                    final status = p['status'] as String;
                    final Color statusColor = switch (status) {
                      "In Stock" => AppColors.success,
                      "Low Stock" => AppColors.warning,
                      _ => AppColors.error,
                    };

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            p['name'],
                            style: AppText.body.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: AppColors.error,
                                ),
                                onPressed: () => updateStock(index, -1),
                              ),
                              Text("${p['stock']}", style: AppText.body),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.success,
                                ),
                                onPressed: () => updateStock(index, 1),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            "\$${(p['price'] as num).toStringAsFixed(2)}",
                            style: AppText.body,
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: AppText.small.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.history,
                                  color: AppColors.secondary,
                                ),
                                onPressed: () => _showHistoryDialog(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.primary,
                                ),
                                onPressed: () =>
                                    _showAddOrEditDialog(editIndex: index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                onPressed: () => _deleteProduct(index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

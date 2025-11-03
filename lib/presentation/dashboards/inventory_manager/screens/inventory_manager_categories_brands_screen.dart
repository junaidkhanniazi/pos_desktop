import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_button.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';

class InventoryManagerCategoriesBrandsScreen extends StatefulWidget {
  const InventoryManagerCategoriesBrandsScreen({super.key});

  @override
  State<InventoryManagerCategoriesBrandsScreen> createState() =>
      _InventoryManagerCategoriesBrandsScreenState();
}

class _InventoryManagerCategoriesBrandsScreenState
    extends State<InventoryManagerCategoriesBrandsScreen> {
  final categories = ["Perfumes", "Mobiles", "Accessories"];
  final Map<String, List<String>> brands = {
    "Perfumes": ["Dior", "Chanel"],
    "Mobiles": ["Apple", "Samsung"],
    "Accessories": ["Generic"],
  };
  String selected = "Perfumes";

  void _addCategoryDialog() {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Category", style: AppText.h2),
              const SizedBox(height: 12),
              AppInput(
                controller: c,
                hint: "Category name",
                icon: Icons.category,
              ),
              const SizedBox(height: 16),
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
                    label: "Add",
                    icon: Icons.add,
                    onPressed: () {
                      if (c.text.trim().isNotEmpty) {
                        setState(() {
                          categories.add(c.text.trim());
                          brands[c.text.trim()] = [];
                        });
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addBrandDialog() {
    final b = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Brand to $selected", style: AppText.h2),
              const SizedBox(height: 12),
              AppInput(
                controller: b,
                hint: "Brand name",
                icon: Icons.sell_outlined,
              ),
              const SizedBox(height: 16),
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
                    label: "Add",
                    icon: Icons.add,
                    onPressed: () {
                      if (b.text.trim().isNotEmpty) {
                        setState(() {
                          brands[selected]!.add(b.text.trim());
                        });
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Categories
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Categories", style: AppText.h2),
                      AppButton(
                        label: "Add",
                        icon: Icons.add,
                        onPressed: _addCategoryDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: AppColors.border),
                      itemBuilder: (_, i) => ListTile(
                        title: Text(
                          categories[i],
                          style: AppText.body.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: selected == categories[i]
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () => setState(() => selected = categories[i]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Brands
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Brands of $selected", style: AppText.h2),
                      AppButton(
                        label: "Add Brand",
                        icon: Icons.add,
                        onPressed: _addBrandDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: brands[selected]!.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: AppColors.border),
                      itemBuilder: (_, i) => ListTile(
                        title: Text(
                          brands[selected]![i],
                          style: AppText.body.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

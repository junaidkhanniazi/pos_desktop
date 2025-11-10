// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:pos_desktop/core/errors/exception_handler.dart';

// import 'package:pos_desktop/core/theme/app_colors.dart';
// import 'package:pos_desktop/core/theme/app_text_styles.dart';
// import 'package:pos_desktop/core/utils/auth_storage_helper.dart';
// import 'package:pos_desktop/core/utils/toast_helper.dart';
// import 'package:pos_desktop/presentation/state_management/controllers/brand_controller.dart';
// import 'package:pos_desktop/presentation/widgets/app_button.dart';
// import 'package:pos_desktop/presentation/widgets/app_input.dart';
// import 'package:pos_desktop/presentation/state_management/controllers/category_controller.dart';
// import 'package:pos_desktop/presentation/state_management/controllers/product_controller.dart';
// import 'package:pos_desktop/data/models/brands_model.dart';

// class OwnerInventoryScreen extends StatefulWidget {
//   const OwnerInventoryScreen({super.key});

//   @override
//   State<OwnerInventoryScreen> createState() => _OwnerInventoryScreenState();
// }

// class _OwnerInventoryScreenState extends State<OwnerInventoryScreen> {
//   final CategoryController _categoryController = Get.find<CategoryController>();
//   final ProductController _productController = Get.find<ProductController>();
//   final BrandController _brandController = Get.find<BrandController>();

//   final List<String> _brands = ["All Brands"];
//   int selectedCategoryIndex = -1; // Start with no category selected
//   String? selectedBrand;

//   @override
//   void initState() {
//     super.initState();
//     selectedBrand = _brands.first;
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     await _categoryController.loadCategories();
//     await _loadBrands();
//     // Don't load products initially - wait for category selection
//   }

//   Future<void> _loadBrands() async {
//     try {
//       print('🟡 [UI] _loadBrands called');

//       // 🔍 STEP 1: Debug current store info
//       await AuthStorageHelper.debugCurrentStore();

//       final ownerId = await AuthStorageHelper.getOwnerId();
//       final email = await AuthStorageHelper.getEmail();
//       final ownerName = email?.split('@').first ?? "owner";
//       final currentStoreId = await AuthStorageHelper.getCurrentStoreId();
//       final currentStoreName = await AuthStorageHelper.getCurrentStoreName();

//       print('   → storeId: $currentStoreId');
//       print('   → ownerId: $ownerId');
//       print('   → storeName: $currentStoreName');
//       print('   → ownerName: $ownerName');

//       // ✅ ADD THIS LINE (important!)
//       print(
//         '📂 [DEBUG] Expected DB path: C:\\Users\\Admin\\Documents\\Pos_Desktop\\owners\\$ownerName\\stores\\$currentStoreName.db',
//       );

//       if (ownerId != null &&
//           currentStoreId != null &&
//           currentStoreName != null) {
//         await _brandController.fetchBrands(
//           storeId: currentStoreId,
//           ownerName: ownerName,
//           ownerId: int.parse(ownerId),
//           storeName: currentStoreName,
//         );

//         print('🟢 [UI] Loaded ${_brandController.brands.length} brands:');
//         _brandController.brands.forEach((brand) {
//           print('   - ${brand.name} (ID: ${brand.id})');
//         });

//         if (_brandController.brands.isNotEmpty) {
//           setState(() {
//             // Only set default if nothing selected yet
//             if (selectedBrand == null ||
//                 !_brandController.brands.any((b) => b.name == selectedBrand)) {
//               selectedBrand = "All Brands";
//               print('⚪ Defaulted brand to All Brands');
//             } else {
//               print('🟢 Keeping previously selected brand: $selectedBrand');
//             }
//           });
//         }
//       }
//     } catch (e) {
//       print('❌ [UI] Error loading brands: $e');
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _categoryController.addListener(_onControllerUpdate);
//     _productController.addListener(_onControllerUpdate);
//     _brandController.addListener(_onControllerUpdate);
//   }

//   @override
//   void dispose() {
//     _categoryController.removeListener(_onControllerUpdate);
//     _productController.removeListener(_onControllerUpdate);
//     _brandController.removeListener(_onControllerUpdate);
//     super.dispose();
//   }

//   void _onControllerUpdate() {
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   // Using controller data - only actual categories, no "All Categories"
//   List<String> get categories => _categoryController.categoryNames;
//   List<String> get brands {
//     final brandNames = _brandController.brands
//         .map((brand) => brand.name)
//         .toList();
//     return ["All Brands", ...brandNames];
//   }

//   String get selectedCategoryName {
//     if (selectedCategoryIndex == -1) return "Select a Category";
//     return _categoryController.getCategoryName(selectedCategoryIndex);
//   }

//   int get selectedCategoryId {
//     if (selectedCategoryIndex == -1) return -1;
//     return _categoryController.getCategoryId(selectedCategoryIndex);
//   }

//   // Get products for current selection
//   List<dynamic> get productsForSelection {
//     if (selectedCategoryIndex == -1) {
//       return []; // No category selected, show empty
//     } else {
//       // Show products only from selected category
//       return _productController.filteredProducts
//           .where((product) => product.categoryId == selectedCategoryId)
//           .toList();
//     }
//   }

//   void _onCategoryTap(int index) async {
//     setState(() => selectedCategoryIndex = index);
//     final categoryId = _categoryController.getCategoryId(index);

//     print('🟡 [UI] Category tapped: $categoryId');
//     print(
//       '🟡 [UI] Available categories: ${_categoryController.categories.length}',
//     );

//     final ownerId = await AuthStorageHelper.getOwnerId();
//     final email = await AuthStorageHelper.getEmail();
//     final ownerName = email?.split('@').first ?? "owner";
//     final currentStoreId = await AuthStorageHelper.getCurrentStoreId();
//     final currentStoreName = await AuthStorageHelper.getCurrentStoreName();

//     // ✅ Load brands only for this category
//     await _brandController.fetchBrandsByCategory(
//       storeId: currentStoreId!,
//       ownerName: ownerName,
//       ownerId: int.parse(ownerId!),
//       storeName: currentStoreName!,
//       categoryId: categoryId,
//     );

//     // ✅ ADD DEBUG INFO
//     print(
//       '🟢 [UI] Loaded ${_brandController.brands.length} brands for category $categoryId',
//     );
//     _brandController.brands.forEach((brand) {
//       print(
//         '   → ${brand.name} (ID: ${brand.id}, category: ${brand.categoryId})',
//       );
//     });

//     // ✅ Smart brand selection retention
//     setState(() {
//       final availableBrandNames = _brandController.brands
//           .map((b) => b.name)
//           .toList();

//       print('🟢 [UI] Available brand names: $availableBrandNames');
//       print('🟢 [UI] Currently selected brand: $selectedBrand');

//       if (selectedBrand != null &&
//           availableBrandNames.contains(selectedBrand)) {
//         print('🟢 Keeping selected brand: $selectedBrand');
//       } else {
//         selectedBrand = "All Brands";
//         print('⚪ Reset brand selection to All Brands');
//       }
//     });

//     // ✅ Load all products of this category
//     await _productController.loadProductsByCategory(categoryId);
//   }

//   void _onBrandChanged(String? value) {
//     if (value == null) return;
//     setState(() => selectedBrand = value);

//     print('🟡 [UI] _onBrandChanged called');
//     print('   → Selected brand: $value');
//     print('   → Selected category index: $selectedCategoryIndex');
//     print('   → Available brands: $brands');

//     if (selectedCategoryIndex != -1) {
//       final categoryId = _categoryController.getCategoryId(
//         selectedCategoryIndex,
//       );

//       print('   → Category ID: $categoryId');

//       // REPLACE THE ENTIRE METHOD WITH THIS:
//       if (value != "All Brands") {
//         try {
//           final brand = _brandController.brands.firstWhere(
//             (b) => b.name == value,
//           );
//           print('   → Found brand: ${brand.name} (ID: ${brand.id})');
//           _productController.loadProductsByCategory(
//             categoryId,
//             brandId: brand.id, // This should NOT be null
//           );
//         } catch (e) {
//           print('❌ [UI] Error finding brand: $e');
//           _productController.loadProductsByCategory(categoryId);
//         }
//       } else {
//         print('   → Loading all brands for category');
//         _productController.loadProductsByCategory(categoryId);
//       }
//     } else {
//       print('❌ [UI] No category selected');
//     }
//   }

//   // ADD THIS ENTIRE METHOD
//   void _filterProductsByBrand(String brandName) {
//     print('🟡 [UI] _filterProductsByBrand called: $brandName');

//     try {
//       final brand = _brandController.brands.firstWhere(
//         (b) => b.name == brandName,
//       );

//       print('   → Brand found: ${brand.name} (ID: ${brand.id})');

//       if (selectedCategoryIndex != -1) {
//         final categoryId = _categoryController.getCategoryId(
//           selectedCategoryIndex,
//         );
//         print(
//           '   → Calling loadProductsByCategory with categoryId: $categoryId, brandId: ${brand.id}',
//         );

//         _productController.loadProductsByCategory(
//           categoryId,
//           brandId: brand.id,
//         );
//       }
//     } catch (e) {
//       print('❌ [UI] Error in brand filtering: $e');
//       if (selectedCategoryIndex != -1) {
//         final categoryId = _categoryController.getCategoryId(
//           selectedCategoryIndex,
//         );
//         _productController.loadProductsByCategory(categoryId);
//       }
//     }
//   }

//   // ---------- Inventory Actions ----------
//   void updateStock(int productId, int change) async {
//     print('🟦 UI.updateStock called: productId=$productId, change=$change');

//     final product = _productController.products.firstWhere(
//       (p) => p.id == productId,
//     );
//     print('🟦 Current product quantity: ${product.quantity}');

//     final newStock = (product.quantity + change).clamp(0, 9999);
//     print('🟦 New stock to set: $newStock');

//     await _productController.updateStock(productId, newStock);
//   }

//   String _getStockStatus(int stock) {
//     return stock == 0
//         ? "Out of Stock"
//         : stock < 10
//         ? "Low Stock"
//         : "In Stock";
//   }

//   Color _getStatusColor(String status) {
//     return switch (status) {
//       "In Stock" => AppColors.success,
//       "Low Stock" => AppColors.warning,
//       _ => AppColors.error,
//     };
//   }

//   void _deleteProduct(int index) {
//     final product = productsForSelection[index];

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: AppColors.surface,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text("Delete Product", style: AppText.h2),
//         content: Text(
//           "Are you sure you want to delete '${product.name}'?",
//           style: AppText.body.copyWith(color: AppColors.textMedium),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Cancel", style: AppText.body),
//           ),
//           AppButton(
//             label: "Delete",
//             icon: Icons.delete_outline,
//             onPressed: () {
//               // TODO: Implement delete product use case
//               // _productController.deleteProduct(product.id!);
//               _productController.refreshProducts();
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showHistoryDialog(int index) {
//     final product = productsForSelection[index];

//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         backgroundColor: AppColors.surface,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: SizedBox(
//             width: 460,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "Stock History — ${product.name}",
//                   style: AppText.h2.copyWith(color: AppColors.textDark),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "Stock history feature coming soon...",
//                   style: AppText.body,
//                 ),
//                 const SizedBox(height: 14),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: AppButton(
//                     label: "Close",
//                     isPrimary: false,
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAddOrEditDialog({int? editIndex}) {
//     final isNew = editIndex == null;
//     final product = isNew ? null : productsForSelection[editIndex];

//     final nameCtrl = TextEditingController(text: product?.name ?? "");
//     final priceCtrl = TextEditingController(
//       text: product?.price.toString() ?? "",
//     );
//     final stockCtrl = TextEditingController(
//       text: product?.quantity.toString() ?? "",
//     );
//     final skuCtrl = TextEditingController(text: product?.sku ?? "");
//     final barcodeCtrl = TextEditingController(text: product?.barcode ?? "");
//     final costPriceCtrl = TextEditingController(
//       text: product?.costPrice?.toString() ?? "",
//     );

//     // ✅ STATE VARIABLES FOR DROPDOWNS
//     int? selectedCategoryIdForProduct;
//     String? selectedBrandForProduct;
//     List<BrandModel> availableBrandsForCategory = [];

//     // ✅ FOR EDITING: PRE-FILL VALUES
//     if (!isNew) {
//       selectedCategoryIdForProduct = product?.categoryId;
//       if (product?.brandId != null) {
//         final brand = _brandController.brands.firstWhere(
//           (b) => b.id == product?.brandId,
//           orElse: () => _brandController.brands.firstWhere(
//             (b) => b.name == selectedBrand,
//           ),
//         );
//         selectedBrandForProduct = brand.name;
//       }
//     }

//     // ✅ FUNCTION TO LOAD BRANDS FOR SELECTED CATEGORY
//     Future<void> _loadBrandsForCategory(
//       int categoryId,
//       void Function(void Function()) setDialogState,
//     ) async {
//       try {
//         final ownerId = await AuthStorageHelper.getOwnerId();
//         final email = await AuthStorageHelper.getEmail();
//         final ownerName = email?.split('@').first ?? "owner";
//         final currentStoreId = await AuthStorageHelper.getCurrentStoreId();
//         final currentStoreName = await AuthStorageHelper.getCurrentStoreName();

//         if (ownerId != null &&
//             currentStoreId != null &&
//             currentStoreName != null) {
//           await _brandController.fetchBrandsByCategory(
//             storeId: currentStoreId,
//             ownerName: ownerName,
//             ownerId: int.parse(ownerId),
//             storeName: currentStoreName,
//             categoryId: categoryId,
//           );

//           print(
//             '✅ Brands fetched: ${_brandController.brands.map((b) => '${b.name} (cat:${b.categoryId})').toList()}',
//           );

//           setDialogState(() {
//             availableBrandsForCategory = _brandController.brands.toList();
//             selectedBrandForProduct = null;
//           });
//         }
//       } catch (e) {
//         print('❌ Error loading brands for category: $e');
//       }
//     }

//     showDialog(
//       context: context,
//       builder: (_) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           return Dialog(
//             backgroundColor: AppColors.surface,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: SizedBox(
//                 width: 460,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       isNew ? "Add Product" : "Edit Product",
//                       style: AppText.h2.copyWith(color: AppColors.textDark),
//                     ),
//                     const SizedBox(height: 18),

//                     // ✅ CATEGORY DROPDOWN
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.background,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: AppColors.border),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Category *",
//                             style: AppText.small.copyWith(
//                               color: AppColors.textMedium,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           DropdownButtonHideUnderline(
//                             child: DropdownButton<int>(
//                               value: selectedCategoryIdForProduct,
//                               isExpanded: true,
//                               hint: Text(
//                                 "Select Category",
//                                 style: AppText.body.copyWith(
//                                   color: AppColors.textLight,
//                                 ),
//                               ),
//                               items: _categoryController.categories.map((
//                                 category,
//                               ) {
//                                 return DropdownMenuItem<int>(
//                                   value: category.id,
//                                   child: Text(
//                                     category.name,
//                                     style: AppText.body.copyWith(
//                                       color: AppColors.textDark,
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (value) async {
//                                 setDialogState(() {
//                                   selectedCategoryIdForProduct = value;
//                                   selectedBrandForProduct = null;
//                                   availableBrandsForCategory = [];
//                                 });

//                                 if (value != null) {
//                                   await _loadBrandsForCategory(
//                                     value,
//                                     setDialogState,
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // ✅ BRAND DROPDOWN (only shows when category is selected)
//                     if (selectedCategoryIdForProduct != null) ...[
//                       const SizedBox(height: 12),
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.background,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: AppColors.border),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Brand",
//                               style: AppText.small.copyWith(
//                                 color: AppColors.textMedium,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: selectedBrandForProduct,
//                                 isExpanded: true,
//                                 hint: Text(
//                                   "Select Brand (Optional)",
//                                   style: AppText.body.copyWith(
//                                     color: AppColors.textLight,
//                                   ),
//                                 ),
//                                 items: [
//                                   DropdownMenuItem<String>(
//                                     value: null,
//                                     child: Text(
//                                       "No Brand",
//                                       style: AppText.body.copyWith(
//                                         color: AppColors.textMedium,
//                                       ),
//                                     ),
//                                   ),
//                                   ...availableBrandsForCategory.map((brand) {
//                                     return DropdownMenuItem<String>(
//                                       value: brand.name,
//                                       child: Text(
//                                         brand.name,
//                                         style: AppText.body.copyWith(
//                                           color: AppColors.textDark,
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ],
//                                 onChanged: (value) {
//                                   setDialogState(() {
//                                     selectedBrandForProduct = value;
//                                   });
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],

//                     const SizedBox(height: 12),
//                     AppInput(
//                       controller: nameCtrl,
//                       hint: "Product Name *",
//                       icon: Icons.inventory_2_outlined,
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: AppInput(
//                             controller: priceCtrl,
//                             hint: "Price (\$) *",
//                             icon: Icons.attach_money,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: AppInput(
//                             controller: stockCtrl,
//                             hint: "Stock Quantity",
//                             icon: Icons.numbers_outlined,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: AppInput(
//                             controller: costPriceCtrl,
//                             hint: "Cost Price (\$)",
//                             icon: Icons.monetization_on_outlined,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: AppInput(
//                             controller: skuCtrl,
//                             hint: "SKU",
//                             icon: Icons.code_outlined,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     AppInput(
//                       controller: barcodeCtrl,
//                       hint: "Barcode",
//                       icon: Icons.qr_code_outlined,
//                     ),
//                     const SizedBox(height: 22),

//                     // ✅ LOADING STATE
//                     Obx(
//                       () => _productController.isLoading.value
//                           ? Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               child: CircularProgressIndicator(
//                                 color: AppColors.primary,
//                               ),
//                             )
//                           : const SizedBox.shrink(),
//                     ),

//                     // ✅ ERROR MESSAGE
//                     Obx(
//                       () => _productController.error.value.isNotEmpty
//                           ? Padding(
//                               padding: const EdgeInsets.only(bottom: 16),
//                               child: Text(
//                                 _productController.error.value,
//                                 style: AppText.small.copyWith(
//                                   color: AppColors.error,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             )
//                           : const SizedBox.shrink(),
//                     ),

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         AppButton(
//                           label: "Cancel",
//                           isPrimary: false,
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         const SizedBox(width: 10),
//                         AppButton(
//                           label: isNew ? "Add" : "Save",
//                           icon: isNew ? Icons.add : Icons.check,
//                           onPressed: () async {
//                             final name = nameCtrl.text.trim();
//                             final price =
//                                 double.tryParse(priceCtrl.text.trim()) ?? 0.0;
//                             final stock =
//                                 int.tryParse(stockCtrl.text.trim()) ?? 0;
//                             final costPrice = double.tryParse(
//                               costPriceCtrl.text.trim(),
//                             );
//                             final sku = skuCtrl.text.trim();
//                             final barcode = barcodeCtrl.text.trim();

//                             try {
//                               // ✅ VALIDATION
//                               if (selectedCategoryIdForProduct == null) {
//                                 AppToast.show(
//                                   context,
//                                   message: "Please select a category",
//                                   type: ToastType.warning,
//                                 );
//                                 return;
//                               }

//                               if (name.isEmpty) {
//                                 AppToast.show(
//                                   context,
//                                   message: "Product name is required",
//                                   type: ToastType.error,
//                                 );
//                                 return;
//                               }

//                               if (price <= 0) {
//                                 AppToast.show(
//                                   context,
//                                   message: "Price must be greater than 0",
//                                   type: ToastType.warning,
//                                 );
//                                 return;
//                               }

//                               // ✅ GET BRAND ID
//                               int? brandId;
//                               if (selectedBrandForProduct != null) {
//                                 try {
//                                   final brand = availableBrandsForCategory
//                                       .firstWhere(
//                                         (b) =>
//                                             b.name == selectedBrandForProduct,
//                                       );
//                                   brandId = brand.id;
//                                   print(
//                                     '🟢 Selected brand: ${brand.name} (ID: ${brand.id})',
//                                   );
//                                 } catch (e) {
//                                   print('🟡 No matching brand found.');
//                                 }
//                               }

//                               // ✅ CALL ADD PRODUCT
//                               if (isNew) {
//                                 final success = await _productController
//                                     .addProduct(
//                                       categoryId: selectedCategoryIdForProduct!,
//                                       name: name,
//                                       price: price,
//                                       sku: sku.isEmpty ? null : sku,
//                                       costPrice: costPrice,
//                                       quantity: stock,
//                                       barcode: barcode.isEmpty ? null : barcode,
//                                       brandId: brandId,
//                                     );

//                                 if (success) {
//                                   Navigator.pop(context);
//                                   AppToast.show(
//                                     context,
//                                     message:
//                                         "Product '$name' added successfully!",
//                                     type: ToastType.success,
//                                   );
//                                 } else {
//                                   AppToast.show(
//                                     context,
//                                     message:
//                                         "Failed to add product: ${_productController.error.value}",
//                                     type: ToastType.error,
//                                   );
//                                 }
//                               } else {
//                                 // TODO: Edit case
//                                 AppToast.show(
//                                   context,
//                                   message: "Edit functionality coming soon!",
//                                   type: ToastType.info,
//                                 );
//                                 Navigator.pop(context);
//                               }
//                             } catch (error) {
//                               final failure = ExceptionHandler.handle(error);
//                               AppToast.show(
//                                 context,
//                                 message: failure.message,
//                                 type: ToastType.error,
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _pillInfo(String label, String value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Row(
//         children: [
//           Text(
//             "$label: ",
//             style: AppText.small.copyWith(color: AppColors.textMedium),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               overflow: TextOverflow.ellipsis,
//               style: AppText.body.copyWith(
//                 color: AppColors.textDark,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------- UI ----------
//   @override
//   Widget build(BuildContext context) {
//     // guard in case brand disappeared
//     if (selectedBrand == null ||
//         !_brandController.brands.any((b) => b.name == selectedBrand)) {
//       selectedBrand = "All Brands";
//     }

//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // TOP: Title + Brand filter + Add
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Inventory",
//                 style: AppText.h1.copyWith(color: AppColors.textDark),
//               ),

//               Row(
//                 children: [
//                   // Brand dropdown (dummy - kept for UI consistency)
//                   // BRAND DROPDOWN WITH REAL DATA
//                   Obx(
//                     () => _brandController.isLoading.value
//                         ? Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 14,
//                               vertical: 12,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColors.surface,
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: AppColors.border),
//                             ),
//                             child: SizedBox(
//                               width: 120,
//                               height: 20,
//                               child: Center(
//                                 child: SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: AppColors.primary,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         : Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 14),
//                             decoration: BoxDecoration(
//                               color: AppColors.surface,
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: AppColors.border),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppColors.shadow.withOpacity(0.06),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: selectedBrand,
//                                 onChanged: _onBrandChanged,
//                                 items: brands
//                                     .map(
//                                       (b) => DropdownMenuItem(
//                                         value: b,
//                                         child: Text(
//                                           b,
//                                           style: AppText.body.copyWith(
//                                             color: AppColors.textDark,
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                     .toList(),
//                               ),
//                             ),
//                           ),
//                   ),
//                   const SizedBox(width: 12),
//                   AppButton(
//                     label: "Add Product",
//                     icon: Icons.add,
//                     onPressed: () => _showAddOrEditDialog(),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // CATEGORY TABS - HORIZONTALLY SCROLLABLE
//           Obx(
//             () => _categoryController.isLoading.value
//                 ? Center(
//                     child: CircularProgressIndicator(color: AppColors.primary),
//                   )
//                 : _categoryController.categories.isEmpty
//                 ? Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: AppColors.background,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.category_outlined,
//                           color: AppColors.textLight,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           "No categories found. Add categories first.",
//                           style: AppText.body.copyWith(
//                             color: AppColors.textMedium,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Container(
//                     height: 46,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: _categoryController.categories.length,
//                       itemBuilder: (context, index) {
//                         final category = _categoryController.categories[index];
//                         final isSelected = selectedCategoryIndex == index;

//                         return Padding(
//                           padding: EdgeInsets.only(
//                             right: 10,
//                             left: index == 0
//                                 ? 0
//                                 : 0, // First item no left margin
//                           ),
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(24),
//                             onTap: () => _onCategoryTap(index),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 220),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 18,
//                                 vertical: 10,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? AppColors.primary
//                                     : AppColors.surface,
//                                 borderRadius: BorderRadius.circular(24),
//                                 border: Border.all(
//                                   color: isSelected
//                                       ? AppColors.primary
//                                       : AppColors.border,
//                                 ),
//                                 boxShadow: isSelected
//                                     ? [
//                                         BoxShadow(
//                                           color: AppColors.shadow.withOpacity(
//                                             0.12,
//                                           ),
//                                           blurRadius: 8,
//                                           offset: const Offset(0, 3),
//                                         ),
//                                       ]
//                                     : [],
//                               ),
//                               child: Text(
//                                 category.name,
//                                 style: isSelected
//                                     ? AppText.button
//                                     : AppText.body.copyWith(
//                                         color: AppColors.textDark,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//           ),

//           const SizedBox(height: 18),

//           // SELECTED CATEGORY INFO
//           if (selectedCategoryIndex != -1)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: Text(
//                 "Showing products for: $selectedCategoryName",
//                 style: AppText.body.copyWith(
//                   color: AppColors.textMedium,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),

//           // PRODUCTS TABLE
//           Expanded(
//             child: Obx(
//               () => _productController.isLoading.value
//                   ? Center(
//                       child: CircularProgressIndicator(
//                         color: AppColors.primary,
//                       ),
//                     )
//                   : _productController.error.value.isNotEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.error_outline,
//                             size: 64,
//                             color: AppColors.error,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             "Error loading products",
//                             style: AppText.h3.copyWith(color: AppColors.error),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _productController.error.value,
//                             style: AppText.body.copyWith(
//                               color: AppColors.textMedium,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 16),
//                           AppButton(
//                             label: "Retry",
//                             icon: Icons.refresh,
//                             onPressed: _productController.refreshProducts,
//                           ),
//                         ],
//                       ),
//                     )
//                   : Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: AppColors.surface,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.shadow.withOpacity(0.08),
//                             blurRadius: 8,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: selectedCategoryIndex == -1
//                           ? Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.category_outlined,
//                                     size: 64,
//                                     color: AppColors.textLight,
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Text(
//                                     "Select a Category",
//                                     style: AppText.h3.copyWith(
//                                       color: AppColors.textMedium,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     "Choose a category from above to view products",
//                                     style: AppText.body.copyWith(
//                                       color: AppColors.textLight,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : productsForSelection.isEmpty
//                           ? Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.inventory_2_outlined,
//                                     size: 64,
//                                     color: AppColors.textLight,
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Text(
//                                     "No products found",
//                                     style: AppText.h3.copyWith(
//                                       color: AppColors.textMedium,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     "No products available in $selectedCategoryName category",
//                                     style: AppText.body.copyWith(
//                                       color: AppColors.textLight,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   AppButton(
//                                     label: "Add Product",
//                                     icon: Icons.add,
//                                     onPressed: () => _showAddOrEditDialog(),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               child: SingleChildScrollView(
//                                 scrollDirection: Axis.vertical,
//                                 child: DataTable(
//                                   headingRowColor: MaterialStateProperty.all(
//                                     AppColors.background,
//                                   ),
//                                   headingTextStyle: AppText.body.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.textDark,
//                                   ),
//                                   dataRowMinHeight: 58,
//                                   dataRowMaxHeight: 58,
//                                   columns: const [
//                                     DataColumn(label: Text("Product Name")),
//                                     DataColumn(label: Text("SKU")),
//                                     DataColumn(label: Text("Stock")),
//                                     DataColumn(label: Text("Price")),
//                                     DataColumn(label: Text("Cost Price")),
//                                     DataColumn(label: Text("Status")),
//                                     DataColumn(label: Text("Actions")),
//                                   ],
//                                   rows: List.generate(productsForSelection.length, (
//                                     index,
//                                   ) {
//                                     final product = productsForSelection[index];
//                                     final status = _getStockStatus(
//                                       product.quantity,
//                                     );
//                                     final Color statusColor = _getStatusColor(
//                                       status,
//                                     );

//                                     return DataRow(
//                                       cells: [
//                                         DataCell(
//                                           Text(
//                                             product.name,
//                                             style: AppText.body.copyWith(
//                                               color: AppColors.textDark,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(
//                                           Text(
//                                             product.sku ?? 'N/A',
//                                             style: AppText.small.copyWith(
//                                               color: AppColors.textMedium,
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(
//                                           Row(
//                                             children: [
//                                               IconButton(
//                                                 icon: const Icon(
//                                                   Icons.remove_circle_outline,
//                                                   color: AppColors.error,
//                                                 ),
//                                                 onPressed: () => updateStock(
//                                                   product.id!,
//                                                   -1,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 "${product.quantity}",
//                                                 style: AppText.body.copyWith(
//                                                   fontWeight: FontWeight.w700,
//                                                 ),
//                                               ),
//                                               IconButton(
//                                                 icon: const Icon(
//                                                   Icons.add_circle_outline,
//                                                   color: AppColors.success,
//                                                 ),
//                                                 onPressed: () =>
//                                                     updateStock(product.id!, 1),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         DataCell(
//                                           Text(
//                                             "\$${product.price.toStringAsFixed(2)}",
//                                             style: AppText.body.copyWith(
//                                               fontWeight: FontWeight.w700,
//                                               color: AppColors.primary,
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(
//                                           Text(
//                                             "\$${(product.costPrice ?? 0).toStringAsFixed(2)}",
//                                             style: AppText.body.copyWith(
//                                               color: AppColors.textMedium,
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 10,
//                                               vertical: 6,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: statusColor.withOpacity(
//                                                 0.12,
//                                               ),
//                                               borderRadius:
//                                                   BorderRadius.circular(20),
//                                             ),
//                                             child: Text(
//                                               status,
//                                               style: AppText.small.copyWith(
//                                                 color: statusColor,
//                                                 fontWeight: FontWeight.w700,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(
//                                           Row(
//                                             children: [
//                                               IconButton(
//                                                 icon: const Icon(
//                                                   Icons.history,
//                                                   color: AppColors.secondary,
//                                                 ),
//                                                 onPressed: () =>
//                                                     _showHistoryDialog(index),
//                                               ),
//                                               IconButton(
//                                                 icon: const Icon(
//                                                   Icons.edit_outlined,
//                                                   color: AppColors.primary,
//                                                 ),
//                                                 onPressed: () =>
//                                                     _showAddOrEditDialog(
//                                                       editIndex: index,
//                                                     ),
//                                               ),
//                                               IconButton(
//                                                 icon: const Icon(
//                                                   Icons.delete_outline,
//                                                   color: AppColors.error,
//                                                 ),
//                                                 onPressed: () =>
//                                                     _deleteProduct(index),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   }),
//                                 ),
//                               ),
//                             ),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

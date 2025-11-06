import 'package:pos_desktop/data/models/brands_model.dart';

class BrandEntity {
  final int? id;
  final int categoryId;
  final String name;
  final String? description;
  final int isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  BrandEntity({
    this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.isSynced = 0,
    this.lastUpdated,
    this.createdAt,
  });

  // Convert BrandEntity to Model
  BrandModel toModel() {
    return BrandModel(
      id: id,
      categoryId: categoryId,
      name: name,
      description: description,
      isSynced: isSynced,
      lastUpdated: lastUpdated,
      createdAt: createdAt,
    );
  }
}

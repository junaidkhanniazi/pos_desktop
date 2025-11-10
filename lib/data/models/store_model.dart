import 'dart:convert';
import 'package:pos_desktop/domain/entities/store/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required int id,
    required int ownerId,
    required String storeName,
    String? folderPath,
    String? dbPath,
    bool isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUpdated,
  }) : super(
         id: id,
         ownerId: ownerId,
         storeName: storeName,
         folderPath: folderPath,
         dbPath: dbPath,
         isSynced: isSynced,
         createdAt: createdAt,
         updatedAt: updatedAt,
         lastUpdated: lastUpdated,
       );

  factory StoreModel.fromEntity(StoreEntity e) => StoreModel(
    id: e.id,
    ownerId: e.ownerId,
    storeName: e.storeName,
    folderPath: e.folderPath,
    dbPath: e.dbPath,
    isSynced: e.isSynced,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
    lastUpdated: e.lastUpdated,
  );

  factory StoreModel.fromMap(Map<String, dynamic> map) => StoreModel(
    id: map['id'] ?? 0,
    ownerId: map['ownerId'] ?? 0,
    storeName: map['storeName'] ?? '',
    folderPath: map['folderPath'],
    dbPath: map['dbPath'],
    isSynced: (map['is_synced'] ?? 0) == 1,
    createdAt: map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt'])
        : null,
    updatedAt: map['updatedAt'] != null
        ? DateTime.tryParse(map['updatedAt'])
        : null,
    lastUpdated: map['last_updated'] != null
        ? DateTime.tryParse(map['last_updated'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'storeName': storeName,
    'folderPath': folderPath,
    'dbPath': dbPath,
    'is_synced': isSynced ? 1 : 0,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'last_updated': lastUpdated?.toIso8601String(),
  };

  factory StoreModel.fromJson(String source) =>
      StoreModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

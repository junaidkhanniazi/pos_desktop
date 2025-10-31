import 'dart:convert';

class StoreModel {
  final int id; // unique store id (timestamp-based)
  final int ownerId;
  final String storeName;
  final String folderPath; // /pos_data/owner_junaid/store_1730.../
  final String dbPath; // full path to .db file
  final DateTime createdAt;
  final DateTime? updatedAt;

  StoreModel({
    required this.id,
    required this.ownerId,
    required this.storeName,
    required this.folderPath,
    required this.dbPath,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert SQLite row → StoreModel
  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'] as int,
      ownerId: map['ownerId'] as int,
      storeName: map['storeName'] as String,
      folderPath: map['folderPath'] as String,
      dbPath: map['dbPath'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  /// Convert model → Map (for DB insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'storeName': storeName,
      'folderPath': folderPath,
      'dbPath': dbPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Encode / Decode (for local JSON caching if needed)
  String toJson() => jsonEncode(toMap());
  factory StoreModel.fromJson(String source) =>
      StoreModel.fromMap(jsonDecode(source));
}

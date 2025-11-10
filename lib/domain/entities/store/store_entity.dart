class StoreEntity {
  final int id;
  final int ownerId;
  final String storeName;
  final String? folderPath;
  final String? dbPath;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastUpdated;

  const StoreEntity({
    required this.id,
    required this.ownerId,
    required this.storeName,
    this.folderPath,
    this.dbPath,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
    this.lastUpdated,
  });

  StoreEntity copyWith({
    int? id,
    int? ownerId,
    String? storeName,
    String? folderPath,
    String? dbPath,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUpdated,
  }) {
    return StoreEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      storeName: storeName ?? this.storeName,
      folderPath: folderPath ?? this.folderPath,
      dbPath: dbPath ?? this.dbPath,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory StoreEntity.fromMap(Map<String, dynamic> map) {
    return StoreEntity(
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
  }

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
}

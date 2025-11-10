class SyncMetadataEntity {
  final int? id;
  final DateTime? lastPushAt;
  final DateTime? lastPullAt;

  const SyncMetadataEntity({this.id, this.lastPushAt, this.lastPullAt});

  factory SyncMetadataEntity.fromMap(Map<String, dynamic> map) {
    return SyncMetadataEntity(
      id: map['id'],
      lastPushAt: map['last_push_at'] != null
          ? DateTime.tryParse(map['last_push_at'])
          : null,
      lastPullAt: map['last_pull_at'] != null
          ? DateTime.tryParse(map['last_pull_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'last_push_at': lastPushAt?.toIso8601String(),
    'last_pull_at': lastPullAt?.toIso8601String(),
  };
}

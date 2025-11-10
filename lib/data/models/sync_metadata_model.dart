import 'dart:convert';
import 'package:pos_desktop/domain/entities/store/sync_metadata_entity.dart';

class SyncMetadataModel extends SyncMetadataEntity {
  const SyncMetadataModel({int? id, DateTime? lastPushAt, DateTime? lastPullAt})
    : super(id: id, lastPushAt: lastPushAt, lastPullAt: lastPullAt);

  factory SyncMetadataModel.fromEntity(SyncMetadataEntity e) =>
      SyncMetadataModel(
        id: e.id,
        lastPushAt: e.lastPushAt,
        lastPullAt: e.lastPullAt,
      );

  factory SyncMetadataModel.fromMap(Map<String, dynamic> map) =>
      SyncMetadataModel(
        id: map['id'] as int?,
        lastPushAt: map['last_push_at'] != null
            ? DateTime.tryParse(map['last_push_at'])
            : null,
        lastPullAt: map['last_pull_at'] != null
            ? DateTime.tryParse(map['last_pull_at'])
            : null,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'last_push_at': lastPushAt?.toIso8601String(),
    'last_pull_at': lastPullAt?.toIso8601String(),
  };

  factory SyncMetadataModel.fromJson(String source) =>
      SyncMetadataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

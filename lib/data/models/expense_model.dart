import 'dart:convert';
import 'package:pos_desktop/domain/entities/store/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    int? id,
    required String title,
    required double amount,
    String? note,
    bool isSynced = false,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) : super(
         id: id,
         title: title,
         amount: amount,
         note: note,
         isSynced: isSynced,
         lastUpdated: lastUpdated,
         createdAt: createdAt,
       );

  factory ExpenseModel.fromEntity(ExpenseEntity e) => ExpenseModel(
    id: e.id,
    title: e.title,
    amount: e.amount,
    note: e.note,
    isSynced: e.isSynced,
    lastUpdated: e.lastUpdated,
    createdAt: e.createdAt,
  );

  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
    id: map['id'] as int?,
    title: map['title'] ?? '',
    amount: (map['amount'] ?? 0).toDouble(),
    note: map['note'],
    isSynced: (map['is_synced'] ?? 0) == 1,
    lastUpdated: map['last_updated'] != null
        ? DateTime.tryParse(map['last_updated'])
        : null,
    createdAt: map['created_at'] != null
        ? DateTime.tryParse(map['created_at'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'note': note,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };

  factory ExpenseModel.fromJson(String source) =>
      ExpenseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}

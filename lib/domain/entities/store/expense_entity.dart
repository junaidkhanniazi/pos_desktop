class ExpenseEntity {
  final int? id;
  final String title;
  final double amount;
  final String? note;
  final bool isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  const ExpenseEntity({
    this.id,
    required this.title,
    required this.amount,
    this.note,
    this.isSynced = false,
    this.lastUpdated,
    this.createdAt,
  });

  factory ExpenseEntity.fromMap(Map<String, dynamic> map) {
    return ExpenseEntity(
      id: map['id'],
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
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'note': note,
    'is_synced': isSynced ? 1 : 0,
    'last_updated': lastUpdated?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };
}

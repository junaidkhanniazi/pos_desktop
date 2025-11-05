class ExpenseModel {
  final int? id;
  final String title;
  final double amount;
  final String? note;
  final int isSynced;
  final DateTime? lastUpdated;
  final DateTime? createdAt;

  ExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    this.note,
    this.isSynced = 0,
    this.lastUpdated,
    this.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount']?.toDouble() ?? 0.0,
      note: map['note'],
      isSynced: map['is_synced'] ?? 0,
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'note': note,
      'is_synced': isSynced,
      'last_updated': lastUpdated?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

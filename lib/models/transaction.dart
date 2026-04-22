enum TransactionType { income, expense }

enum TransactionCategory { salary, food, transport, shopping, other }

extension TransactionCategoryExt on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.salary: return 'Salary';
      case TransactionCategory.food: return 'Food';
      case TransactionCategory.transport: return 'Transport';
      case TransactionCategory.shopping: return 'Shopping';
      case TransactionCategory.other: return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case TransactionCategory.salary: return '💰';
      case TransactionCategory.food: return '🍔';
      case TransactionCategory.transport: return '🚌';
      case TransactionCategory.shopping: return '🛒';
      case TransactionCategory.other: return '📦';
    }
  }
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  bool get isIncome => type == TransactionType.income;

  // ── SQLite serialization ───────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'date': date.millisecondsSinceEpoch,
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TransactionCategory.other,
      ),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }
}
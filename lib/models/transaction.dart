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
}
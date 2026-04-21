import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
import '../widgets/set_budget_sheet.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? _budget;
  final List<Transaction> _transactions = [];
  DateTime? _selectedDate;
  int _currentIndex = 0;

  double get _totalIn => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalOut => _transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  List<Transaction> get _filteredTransactions {
    if (_selectedDate == null) return _transactions;
    return _transactions.where((t) {
      return t.date.year == _selectedDate!.year &&
          t.date.month == _selectedDate!.month &&
          t.date.day == _selectedDate!.day;
    }).toList();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _addTransaction(Transaction t) {
    setState(() => _transactions.insert(0, t));
  }

  Future<void> _showSetBudget() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SetBudgetSheet(),
    );
    if (result != null) setState(() => _budget = result);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _clearDate() => setState(() => _selectedDate = null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomePage(),
          AddTransactionScreen(
            recentTransactions: _transactions,
            onAdd: _addTransaction,
          ),
          _buildAnalyticsPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────── HOME PAGE ────────────────────────────

  Widget _buildHomePage() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildBudgetCard(),
                const SizedBox(height: 24),
                _buildTransactionSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  children: [
                    TextSpan(text: 'BUR'),
                    TextSpan(
                      text: '\$',
                      style: TextStyle(color: Color(0xFFFFD700)),
                    ),
                    TextSpan(text: 'A'),
                  ],
                ),
              ),
              Text(
                widget.userName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_greeting}, ${widget.userName}!',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    final fmt = NumberFormat('#,##0.00');
    final remainingBudget =
        _budget == null ? null : (_budget! + _totalIn - _totalOut);
    final progress = _budget == null || _budget == 0
        ? 0.0
        : (remainingBudget! / _budget!).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'REMAINING BUDGET',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF888888),
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: _showSetBudget,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6A800),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _budget == null
                ? '—'
                : '₱${fmt.format(remainingBudget)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('₱0',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
              Text(
                _budget == null
                    ? 'Budget: —'
                    : 'Budget: ₱${fmt.format(_budget)}',
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _budget == null ? 0 : progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE6A800)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryBox(
                  label: 'Total in',
                  value: '+₱${fmt.format(_totalIn)}',
                  color: const Color(0xFFE6A800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryBox(
                  label: 'Total out',
                  value: '-₱${fmt.format(_totalOut)}',
                  color: const Color(0xFFCC8800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTransactionSection() {
    final filtered = _filteredTransactions;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions History',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A)),
            ),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: AppColors.primaryGreen, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: _selectedDate == null ? _pickDate : _clearDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppColors.primaryGreen
                        : const Color(0xFFDDDDDD),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Display the date here'
                          : DateFormat('MMM d, yyyy').format(_selectedDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: _selectedDate != null
                            ? AppColors.primaryGreen
                            : const Color(0xFF888888),
                        fontWeight: _selectedDate != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.close,
                          size: 14, color: AppColors.primaryGreen),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: filtered.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: filtered
                      .map((t) => TransactionItem(transaction: t))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          const Text('No transactions yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF888888))),
          const SizedBox(height: 6),
          const Text(
            'Successful transactions will\nappear in this section.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Color(0xFFAAAAAA), height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── ANALYTICS PAGE ───────────────────────

  Widget _buildAnalyticsPage() {
    final fmt = NumberFormat('#,##0.00');
    final incomeTransactions = _transactions.where((t) => t.isIncome).toList();
    final expenseTransactions =
        _transactions.where((t) => !t.isIncome).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Analytics',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _analyticsCard(
                    '💚 Total Income',
                    '₱${fmt.format(_totalIn)}',
                    const Color(0xFFE8F5E9),
                    const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _analyticsCard(
                    '❤️ Total Expense',
                    '₱${fmt.format(_totalOut)}',
                    const Color(0xFFFFEBEE),
                    const Color(0xFFE53935),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _analyticsCard(
              '💼 Net Balance',
              '₱${fmt.format(_totalIn - _totalOut)}',
              const Color(0xFFFFF8E1),
              const Color(0xFFE6A800),
            ),
            const SizedBox(height: 24),
            Text(
              '${_transactions.length} total transaction${_transactions.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _analyticsCard(
      String label, String value, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor)),
        ],
      ),
    );
  }

  // ─────────────────────────── BOTTOM NAV ───────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x10000000),
              blurRadius: 12,
              offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.add_circle_outline_rounded, 'Add'),
              _navItem(2, Icons.bar_chart_rounded, 'Analytics'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    final color =
        isActive ? AppColors.primaryGreen : const Color(0xFFAAAAAA);
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}
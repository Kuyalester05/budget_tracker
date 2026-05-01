import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transaction> _transactions = [];
  DateTime? _selectedDate;
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    final List<Transaction> transactions =
        await DatabaseHelper.instance.getAllTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

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

  Future<void> _addTransaction(Transaction t) async {
    await DatabaseHelper.instance.insertTransaction(t);
    setState(() {
      _transactions.insert(0, t);
      _currentIndex = 0;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primaryGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _clearDate() => setState(() => _selectedDate = null);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.offWhite,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomePage(),
          AddTransactionScreen(
            recentTransactions: _transactions,
            onAdd: _addTransaction,
          ),
          AnalyticsScreen(
            transactions: _transactions,
            onBack: () => setState(() => _currentIndex = 0),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────── HOME PAGE ────────────────────────────────

  Widget _buildHomePage() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            child: Column(
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 22),
                _buildQuickStats(),
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
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 58, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.5,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    TextSpan(text: 'BUR'),
                    TextSpan(
                      text: '\$',
                      style: TextStyle(color: AppColors.goldPrimary),
                    ),
                    TextSpan(text: 'A'),
                  ],
                ),
              ),
              // User avatar chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.userName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.userName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${_greeting}, ${widget.userName}! 👋',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.65),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final fmt = NumberFormat('#,##0.00');
    final netBalance = _totalIn - _totalOut;
    final isPositive = netBalance >= 0;

    return Transform.translate(
      offset: const Offset(0, -14),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFBEF), Color(0xFFFFF5CC)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.floatingShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'REMAINING BALANCE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldDeep,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppColors.incomeGreen.withOpacity(0.12)
                        : AppColors.expenseRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPositive ? '▲ Surplus' : '▼ Deficit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPositive
                          ? AppColors.incomeGreen
                          : AppColors.expenseRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '₱${fmt.format(netBalance)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    label: 'Money In',
                    value: '+₱${fmt.format(_totalIn)}',
                    gradient: AppColors.incomeGradient,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryBox(
                    label: 'Money Out',
                    value: '-₱${fmt.format(_totalOut)}',
                    gradient: AppColors.expenseGradient,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox({
    required String label,
    required String value,
    required LinearGradient gradient,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final txCount = _transactions.length;
    final incomeCount = _transactions.where((t) => t.isIncome).length;
    return Row(
      children: [
        _statChip(Icons.receipt_long_rounded, '$txCount', 'Transactions'),
        const SizedBox(width: 10),
        _statChip(Icons.trending_up_rounded, '$incomeCount', 'Income entries'),
        const SizedBox(width: 10),
        _statChip(Icons.trending_down_rounded,
            '${txCount - incomeCount}', 'Expenses'),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryGreen),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSection() {
    final filtered = _filteredTransactions;
    return Column(
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: AppColors.primaryGreen, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Date filter chip
        if (_selectedDate != null || true)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _selectedDate == null ? _pickDate : _clearDate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _selectedDate != null
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppColors.primaryGreen
                        : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedDate != null
                          ? Icons.event_available_rounded
                          : Icons.filter_list_rounded,
                      size: 14,
                      color: _selectedDate != null
                          ? AppColors.primaryGreen
                          : AppColors.textGrey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedDate == null
                          ? 'Filter by date'
                          : DateFormat('MMM d, yyyy').format(_selectedDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: _selectedDate != null
                            ? AppColors.primaryGreen
                            : AppColors.textGrey,
                        fontWeight: _selectedDate != null
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.close_rounded,
                          size: 13, color: AppColors.primaryGreen),
                    ],
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 14),
        // Transaction list card
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: filtered.isEmpty
              ? _buildEmptyState()
              : Column(
                  children:
                      filtered.map((t) => TransactionItem(transaction: t)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 34, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          const Text('No transactions yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMid,
              )),
          const SizedBox(height: 6),
          const Text(
            'Tap the + tab below to add your\nfirst transaction.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: AppColors.textGrey, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────── BOTTOM NAV ───────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.deepForest.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _navItem(0, Icons.home_rounded, 'Home'),
                  ),
                  const SizedBox(width: 70),
                  Expanded(
                    child: _navItem(2, Icons.bar_chart_rounded, 'Analytics'),
                  ),
                ],
              ),
              _navItemCenter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(icon,
                key: ValueKey(isActive),
                color: isActive ? AppColors.primaryGreen : AppColors.textLight,
                size: isActive ? 26 : 24),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.primaryGreen
                      : AppColors.textLight,
                )),
          ],
        ),
      ),
    );
  }

  Widget _navItemCenter() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 1),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 150),
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: child,
        ),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
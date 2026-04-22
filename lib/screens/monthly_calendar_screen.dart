import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';

class MonthlyCalendarScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final DateTime initialMonth;

  const MonthlyCalendarScreen({
    super.key,
    required this.transactions,
    required this.initialMonth,
  });

  @override
  State<MonthlyCalendarScreen> createState() => _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends State<MonthlyCalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  bool _showIncome = true;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month);
    _selectedDate = DateTime.now();
  }

  // ── helpers ──────────────────────────────────────────────────────────

  List<Transaction> get _monthTx => widget.transactions.where((t) =>
      t.date.year == _currentMonth.year &&
      t.date.month == _currentMonth.month).toList();

  List<Transaction> _txForDate(DateTime date) => widget.transactions.where((t) =>
      t.date.year == date.year &&
      t.date.month == date.month &&
      t.date.day == date.day).toList();

  double _incomeForDate(DateTime date) =>
      _txForDate(date).where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);

  double _expenseForDate(DateTime date) =>
      _txForDate(date).where((t) => !t.isIncome).fold(0, (s, t) => s + t.amount);

  double get _selectedIncome =>
      _selectedDate == null ? 0 : _incomeForDate(_selectedDate!);

  double get _selectedExpense =>
      _selectedDate == null ? 0 : _expenseForDate(_selectedDate!);

  List<Transaction> get _filteredList {
    if (_selectedDate == null) return [];
    return _txForDate(_selectedDate!)
        .where((t) => t.isIncome == _showIncome)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  bool _hasTransactions(DateTime date) => _txForDate(date).isNotEmpty;

  String get _monthRangeLabel {
    final start = DateFormat('MMM dd').format(
        DateTime(_currentMonth.year, _currentMonth.month, 1));
    final end = DateFormat('MMM dd').format(
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0));
    return '$start - $end';
  }

  void _prevMonth() => setState(() {
        _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month - 1);
        _selectedDate = null;
      });

  void _nextMonth() => setState(() {
        _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month + 1);
        _selectedDate = null;
      });

  // ── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSummaryCards(fmt),
                    const SizedBox(height: 24),
                    _buildCalendarCard(),
                    const SizedBox(height: 24),
                    _buildTabsAndList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── top bar ───────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 12, 16, 4),
      child: Row(
        children: [
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  // ── summary cards ─────────────────────────────────────────────────────

  Widget _buildSummaryCards(NumberFormat fmt) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Daily total Income',
            value: '₱${fmt.format(_selectedIncome)}',
            icon: Icons.attach_money_rounded,
            bgColor: const Color(0xFFE8F5E8),
            iconColor: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Daily total expense',
            value: '₱${fmt.format(_selectedExpense)}',
            icon: Icons.money_off_rounded,
            bgColor: const Color(0xFFFFF8E1),
            iconColor: const Color(0xFFE6A800),
          ),
        ),
      ],
    );
  }

  // ── calendar card ─────────────────────────────────────────────────────

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics title + month range
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _monthRangeLabel,
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 16),

          // Month navigation
          Row(
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    // First day of month and total days
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun, 6=Sat

    // Previous month fill days
    final prevMonthDays =
        DateTime(_currentMonth.year, _currentMonth.month, 0).day;

    return Column(
      children: [
        // Day headers
        Row(
          children: daysOfWeek.map((d) {
            final isSun = d == 'Su';
            final isSat = d == 'Sa';
            return Expanded(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),

        // Day cells
        ..._buildWeekRows(
            startWeekday, daysInMonth, prevMonthDays),
      ],
    );
  }

  List<Widget> _buildWeekRows(
      int startWeekday, int daysInMonth, int prevMonthDays) {
    final cells = <_DayCell>[];

    // Fill leading days from previous month
    for (int i = startWeekday - 1; i >= 0; i--) {
      cells.add(_DayCell(
        day: prevMonthDays - i,
        isCurrentMonth: false,
        date: DateTime(
            _currentMonth.year, _currentMonth.month - 1, prevMonthDays - i),
      ));
    }

    // Current month days
    for (int d = 1; d <= daysInMonth; d++) {
      final date =
          DateTime(_currentMonth.year, _currentMonth.month, d);
      cells.add(_DayCell(
        day: d,
        isCurrentMonth: true,
        date: date,
        isToday: _isToday(date),
        isSelected: _selectedDate != null &&
            _selectedDate!.year == date.year &&
            _selectedDate!.month == date.month &&
            _selectedDate!.day == date.day,
        hasTransactions: _hasTransactions(date),
      ));
    }

    // Fill trailing days from next month
    final remainder = (7 - (cells.length % 7)) % 7;
    for (int d = 1; d <= remainder; d++) {
      cells.add(_DayCell(
        day: d,
        isCurrentMonth: false,
        date: DateTime(
            _currentMonth.year, _currentMonth.month + 1, d),
      ));
    }

    // Split into weeks
    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final week = cells.sublist(i, i + 7);
      rows.add(Row(
        children: week.map((cell) {
          return Expanded(
            child: GestureDetector(
              onTap: cell.isCurrentMonth
                  ? () => setState(() => _selectedDate = cell.date)
                  : null,
              child: _buildDayCell(cell),
            ),
          );
        }).toList(),
      ));
    }
    return rows;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildDayCell(_DayCell cell) {
    Color textColor;
    Color bgColor = Colors.transparent;
    FontWeight fontWeight = FontWeight.w400;

    if (!cell.isCurrentMonth) {
      textColor = const Color(0xFFCCCCCC);
    } else if (cell.isSelected) {
      bgColor = AppColors.primaryGreen;
      textColor = Colors.white;
      fontWeight = FontWeight.w700;
    } else if (cell.isToday) {
      bgColor = Colors.transparent;
      textColor = AppColors.primaryGreen;
      fontWeight = FontWeight.w700;
    } else {
      textColor = const Color(0xFF1A1A1A);
    }

    return Container(
      height: 44,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: cell.isToday && !cell.isSelected
            ? Border.all(color: AppColors.primaryGreen, width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${cell.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: fontWeight,
              color: textColor,
            ),
          ),
          // Dot indicator for dates with transactions
          if (cell.isCurrentMonth && cell.hasTransactions && !cell.isSelected)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: cell.isToday
                    ? AppColors.primaryGreen
                    : const Color(0xFFE6A800),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // ── tabs + list ───────────────────────────────────────────────────────

  Widget _buildTabsAndList() {
    return Column(
      children: [
        _buildTabs(),
        const SizedBox(height: 16),
        _buildTransactionList(),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Income',
              isActive: _showIncome,
              activeColor: AppColors.primaryGreen,
              onTap: () => setState(() => _showIncome = true),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Expenses',
              isActive: !_showIncome,
              activeColor: const Color(0xFFE6A800),
              onTap: () => setState(() => _showIncome = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final list = _filteredList;

    if (_selectedDate == null) {
      return _emptyState('Tap a date to view transactions');
    }

    if (list.isEmpty) {
      return _emptyState(
          'No ${_showIncome ? 'income' : 'expenses'} on ${DateFormat('MMM d').format(_selectedDate!)}');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 72, color: Color(0xFFF0F0F0)),
        itemBuilder: (_, i) => _TxItem(transaction: list[i]),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 44, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── data model ────────────────────────────────────────────────────────────────

class _DayCell {
  final int day;
  final bool isCurrentMonth;
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool hasTransactions;

  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.date,
    this.isToday = false,
    this.isSelected = false,
    this.hasTransactions = false,
  });
}

// ── subwidgets ────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isActive ? Colors.white : const Color(0xFF888888),
            ),
          ),
        ),
      ),
    );
  }
}

class _TxItem extends StatelessWidget {
  final Transaction transaction;
  const _TxItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color =
        isIncome ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final bgColor =
        isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final prefix = isIncome ? '+₱' : '-₱';
    final fmt = NumberFormat('#,##0');
    final timeStr = DateFormat('MMM d, h:mm a').format(transaction.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(transaction.category.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          Text(
            '$prefix${fmt.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
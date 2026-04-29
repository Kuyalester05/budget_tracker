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
    _currentMonth =
        DateTime(widget.initialMonth.year, widget.initialMonth.month);
    _selectedDate = DateTime.now();
  }

  List<Transaction> get _monthTx => widget.transactions
      .where((t) =>
          t.date.year == _currentMonth.year &&
          t.date.month == _currentMonth.month)
      .toList();

  List<Transaction> _txForDate(DateTime date) =>
      widget.transactions
          .where((t) =>
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day)
          .toList();

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
    final start = DateFormat('MMM dd')
        .format(DateTime(_currentMonth.year, _currentMonth.month, 1));
    final end = DateFormat('MMM dd')
        .format(DateTime(_currentMonth.year, _currentMonth.month + 1, 0));
    return '$start – $end';
  }

  void _prevMonth() => setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
        _selectedDate = null;
      });

  void _nextMonth() => setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
        _selectedDate = null;
      });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSummaryCards(fmt),
                    const SizedBox(height: 20),
                    _buildCalendarCard(),
                    const SizedBox(height: 20),
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

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(13),
                boxShadow: AppColors.cardShadow,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Monthly Calendar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(NumberFormat fmt) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Daily Income',
            value: '₱${fmt.format(_selectedIncome)}',
            icon: Icons.south_rounded,
            gradient: AppColors.incomeGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Daily Expense',
            value: '₱${fmt.format(_selectedExpense)}',
            icon: Icons.north_rounded,
            gradient: AppColors.expenseGradient,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(_monthRangeLabel,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _prevMonth,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 13, color: AppColors.primaryGreen),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      DateFormat('MMMM yyyy').format(_currentMonth),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 13, color: AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final prevMonthDays =
        DateTime(_currentMonth.year, _currentMonth.month, 0).day;

    return Column(
      children: [
        Row(
          children: daysOfWeek.map((d) {
            return Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 8),
        ..._buildWeekRows(startWeekday, daysInMonth, prevMonthDays),
      ],
    );
  }

  List<Widget> _buildWeekRows(
      int startWeekday, int daysInMonth, int prevMonthDays) {
    final cells = <_DayCell>[];

    for (int i = startWeekday - 1; i >= 0; i--) {
      cells.add(_DayCell(
        day: prevMonthDays - i,
        isCurrentMonth: false,
        date: DateTime(
            _currentMonth.year, _currentMonth.month - 1, prevMonthDays - i),
      ));
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, d);
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

    final remainder = (7 - (cells.length % 7)) % 7;
    for (int d = 1; d <= remainder; d++) {
      cells.add(_DayCell(
        day: d,
        isCurrentMonth: false,
        date: DateTime(_currentMonth.year, _currentMonth.month + 1, d),
      ));
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final week = cells.sublist(i, i + 7);
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
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
        ),
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
    FontWeight fontWeight = FontWeight.w500;

    if (!cell.isCurrentMonth) {
      textColor = AppColors.textLight;
    } else if (cell.isSelected) {
      bgColor = AppColors.primaryGreen;
      textColor = Colors.white;
      fontWeight = FontWeight.w800;
    } else if (cell.isToday) {
      bgColor = Colors.transparent;
      textColor = AppColors.primaryGreen;
      fontWeight = FontWeight.w800;
    } else {
      textColor = AppColors.textDark;
    }

    return Container(
      height: 46,
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
          if (cell.isCurrentMonth && cell.hasTransactions && !cell.isSelected)
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: cell.isToday
                    ? AppColors.primaryGreen
                    : AppColors.goldPrimary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabsAndList() {
    return Column(
      children: [
        _buildTabs(),
        const SizedBox(height: 14),
        _buildTransactionList(),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
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
          )),
          Expanded(
              child: _TabButton(
            label: 'Expenses',
            isActive: !_showIncome,
            activeColor: AppColors.goldDeep,
            onTap: () => setState(() => _showIncome = false),
          )),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final list = _filteredList;

    if (_selectedDate == null) {
      return _emptyState('Tap a date to see transactions');
    }

    if (list.isEmpty) {
      return _emptyState(
          'No ${_showIncome ? 'income' : 'expenses'} on ${DateFormat('MMM d').format(_selectedDate!)}');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 74, color: AppColors.divider),
        itemBuilder: (_, i) => _TxItem(transaction: list[i]),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 28, color: AppColors.textLight),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

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

// ── Subwidgets ────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
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
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isActive ? Colors.white : AppColors.textGrey,
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
    final color = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final bgColor =
        isIncome ? const Color(0xFFE8F7EE) : const Color(0xFFFFEBEA);
    final prefix = isIncome ? '+₱' : '-₱';
    final fmt = NumberFormat('#,##0');
    final timeStr = DateFormat('MMM d, h:mm a').format(transaction.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
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
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(timeStr,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          Text(
            '$prefix${fmt.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
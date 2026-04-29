import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
import 'monthly_calendar_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final VoidCallback? onBack;

  const AnalyticsScreen({super.key, required this.transactions, this.onBack});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _showIncome = true;
  DateTime _selectedMonth = DateTime.now();
  DateTime? _filterDate;

  List<Transaction> get _monthTx => widget.transactions.where((t) {
        return t.date.year == _selectedMonth.year &&
            t.date.month == _selectedMonth.month;
      }).toList();

  double get _totalIncome =>
      _monthTx.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);

  double get _totalExpense =>
      _monthTx.where((t) => !t.isIncome).fold(0, (s, t) => s + t.amount);

  List<Transaction> get _filtered {
    var list = _monthTx.where((t) => t.isIncome == _showIncome).toList();
    if (_filterDate != null) {
      list = list
          .where((t) =>
              t.date.year == _filterDate!.year &&
              t.date.month == _filterDate!.month &&
              t.date.day == _filterDate!.day)
          .toList();
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<_WeekData> get _weeklyData {
    final weeks = List.generate(4, (_) => _WeekData());
    for (final t in _monthTx) {
      final weekIdx = ((t.date.day - 1) ~/ 7).clamp(0, 3);
      if (t.isIncome) {
        weeks[weekIdx].income += t.amount;
      } else {
        weeks[weekIdx].expense += t.amount;
      }
    }
    return weeks;
  }

  String get _monthLabel => DateFormat('MMM yyyy').format(_selectedMonth);

  Future<void> _pickFilterDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ??
          DateTime(_selectedMonth.year, _selectedMonth.month),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primaryGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _filterDate = picked;
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _clearFilterDate() => setState(() => _filterDate = null);

  @override
  Widget build(BuildContext context) {
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
                    _buildSummaryCards(),
                    const SizedBox(height: 20),
                    _buildStatisticsSection(),
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
            onTap: widget.onBack,
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
            'Analytics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _monthLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final fmt = NumberFormat('#,##0');
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Monthly Income',
            value: '₱${fmt.format(_totalIncome)}',
            icon: Icons.south_rounded,
            gradient: AppColors.incomeGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Monthly Expense',
            value: '₱${fmt.format(_totalExpense)}',
            icon: Icons.north_rounded,
            gradient: AppColors.expenseGradient,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    final weeks = _weeklyData;
    final allValues =
        weeks.expand((w) => [w.income, w.expense]).toList();
    final maxVal =
        allValues.isEmpty ? 1.0 : allValues.reduce((a, b) => a > b ? a : b);

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
                    'Weekly Overview',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _filterDate != null
                        ? DateFormat('MMM d, yyyy').format(_filterDate!)
                        : _monthLabel,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _filterDate != null
                        ? _clearFilterDate
                        : _pickFilterDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _filterDate != null
                            ? AppColors.primaryGreen.withOpacity(0.1)
                            : AppColors.offWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _filterDate != null
                              ? AppColors.primaryGreen
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _filterDate != null
                                ? DateFormat('MMM d')
                                    .format(_filterDate!)
                                : _monthLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: _filterDate != null
                                  ? AppColors.primaryGreen
                                  : AppColors.textMid,
                              fontWeight: _filterDate != null
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _filterDate != null
                                ? Icons.close_rounded
                                : Icons.calendar_today_rounded,
                            size: 11,
                            color: _filterDate != null
                                ? AppColors.primaryGreen
                                : AppColors.textGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MonthlyCalendarScreen(
                          transactions: widget.transactions,
                          initialMonth: _selectedMonth,
                        ),
                      ));
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.deepForest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              _legendDot(AppColors.primaryGreen, 'Income'),
              const SizedBox(width: 14),
              _legendDot(AppColors.goldPrimary, 'Expense'),
            ],
          ),
          const SizedBox(height: 18),
          _buildBarChart(weeks, maxVal),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBarChart(List<_WeekData> weeks, double maxVal) {
    final yLabels = _yAxisLabels(maxVal);

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: yLabels.reversed
                .map((v) => Text(
                      _formatYLabel(v),
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textLight),
                    ))
                .toList(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(4, (i) {
                      return _BarGroup(
                        weekNum: i + 1,
                        income: weeks[i].income,
                        expense: weeks[i].expense,
                        maxVal: maxVal == 0 ? 1 : maxVal,
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.divider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<double> _yAxisLabels(double max) {
    if (max == 0) return [0, 1000, 2000, 3000, 4000, 5000];
    final step = _niceStep(max / 4);
    return List.generate(6, (i) => i * step);
  }

  double _niceStep(double raw) {
    if (raw <= 100) return 100;
    if (raw <= 250) return 250;
    if (raw <= 500) return 500;
    if (raw <= 1000) return 1000;
    return (raw / 1000).ceil() * 1000.0;
  }

  String _formatYLabel(double v) {
    if (v >= 1000) return '₱${(v / 1000).toStringAsFixed(0)}K';
    return '₱${v.toInt()}';
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
    final list = _filtered;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 44),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 30, color: AppColors.textLight),
            ),
            const SizedBox(height: 14),
            Text(
              'No ${_showIncome ? 'income' : 'expense'} this month',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
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
            const Divider(height: 1, indent: 72, color: AppColors.divider),
        itemBuilder: (_, i) => _AnalyticsTxItem(transaction: list[i]),
      ),
    );
  }
}

// ── subwidgets ───────────────────────────────────────────────────────────────

class _WeekData {
  double income = 0;
  double expense = 0;
}

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

class _BarGroup extends StatelessWidget {
  final int weekNum;
  final double income;
  final double expense;
  final double maxVal;

  const _BarGroup({
    required this.weekNum,
    required this.income,
    required this.expense,
    required this.maxVal,
  });

  @override
  Widget build(BuildContext context) {
    const maxBarHeight = 130.0;
    final incomeH =
        (income / maxVal * maxBarHeight).clamp(3.0, maxBarHeight);
    final expenseH =
        (expense / maxVal * maxBarHeight).clamp(3.0, maxBarHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Bar(height: incomeH, color: AppColors.primaryGreen),
            const SizedBox(width: 5),
            _Bar(height: expenseH, color: AppColors.goldPrimary),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'W$weekNum',
          style: const TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      width: 18,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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

class _AnalyticsTxItem extends StatelessWidget {
  final Transaction transaction;
  const _AnalyticsTxItem({required this.transaction});

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
                Text(
                  timeStr,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textGrey),
                ),
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
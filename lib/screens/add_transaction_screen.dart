import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  final List<Transaction> recentTransactions;
  final Future<void> Function(Transaction) onAdd;
  final VoidCallback? onBack;

  const AddTransactionScreen({
    super.key,
    required this.recentTransactions,
    required this.onAdd,
    this.onBack,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _type = TransactionType.income;
  double _amount = 0;
  TransactionCategory _category = TransactionCategory.salary;
  DateTime _date = DateTime.now();
  final _descController = TextEditingController();

  static const List<double> _quickAmounts = [50, 100, 200, 500, 1000];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _addQuickAmount(double val) => setState(() => _amount += val);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
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
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_amount <= 0) {
      _showSnack('Please enter an amount greater than ₱0.', isError: true);
      return;
    }
    final now = DateTime.now();
    final transactionDate = DateTime(
      _date.year, _date.month, _date.day,
      now.hour, now.minute, now.second,
    );
    final desc = _descController.text.trim();
    final transaction = Transaction(
      id: now.millisecondsSinceEpoch.toString(),
      title: desc.isEmpty ? _category.label : desc,
      amount: _amount,
      type: _type,
      category: _category,
      date: transactionDate,
    );
    await widget.onAdd(transaction);
    setState(() {
      _amount = 0;
      _date = DateTime.now();
      _descController.clear();
      _category = TransactionCategory.salary;
      _type = TransactionType.income;
    });
    if (!mounted) return;
    _showSnack('Transaction saved!', isError: false);
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? AppColors.expenseRed : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildTypeToggle(),
              const SizedBox(height: 22),
              _buildAmountCard(),
              const SizedBox(height: 18),
              _buildSectionCard(
                child: _buildCategorySection(),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                child: Column(
                  children: [
                    _buildDateSection(),
                    const SizedBox(height: 18),
                    _buildDescriptionSection(),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _buildSaveButton(),
              const SizedBox(height: 28),
              _buildRecentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
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
          const SizedBox(width: 12),
          const Text(
            'Add Transaction',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      children: [
        Expanded(
            child: _typeButton(
          'Income',
          '💰',
          TransactionType.income,
          AppColors.incomeGradient,
          const Color(0xFFE8F7EE),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: _typeButton(
          'Expense',
          '💸',
          TransactionType.expense,
          AppColors.expenseGradient,
          const Color(0xFFFFF8E0),
        )),
      ],
    );
  }

  Widget _typeButton(String label, String emoji, TransactionType type,
      LinearGradient activeGradient, Color inactiveBg) {
    final isSelected = _type == type;
    return _PressableScale(
      onTap: () => setState(() => _type = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: isSelected ? activeGradient : null,
          color: isSelected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected ? AppColors.floatingShadow : AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(
              'Add $label',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textGrey,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final fmt = NumberFormat('#,##0.00');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.floatingShadow,
      ),
      child: Column(
        children: [
          const Text(
            'AMOUNT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white54,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showAmountDialog,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _amount == 0 ? 'Tap to enter' : '₱${fmt.format(_amount)}',
                  style: TextStyle(
                    fontSize: _amount == 0 ? 32 : 38,
                    fontWeight: FontWeight.w900,
                    color: _amount == 0
                        ? Colors.white70
                        : AppColors.goldLight,
                    letterSpacing: _amount == 0 ? 0.5 : -1.5,
                  ),
                ),
                if (_amount > 0) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => _amount = 0),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Quick amount chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _quickAmounts.map((val) {
              return GestureDetector(
                onTap: () => _addQuickAmount(val),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    '+₱${val.toInt()}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showAmountDialog() {
    final ctrl = TextEditingController(
        text: _amount > 0 ? _amount.toStringAsFixed(2) : '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Enter Amount',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₱ ',
            hintText: '0.00',
            filled: true,
            fillColor: AppColors.offWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val >= 0) setState(() => _amount = val);
              Navigator.pop(context);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = TransactionCategory.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            )),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = _category == cat;
            return _PressableScale(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.buttonGradient : null,
                  color: isSelected ? null : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected ? AppColors.cardShadow : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            )),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryGreen,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_date),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.calendar_month_rounded,
                    color: AppColors.primaryGreen,
                    size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            )),
        const SizedBox(height: 10),
        TextField(
          controller: _descController,
          style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'e.g. Monthly Salary',
            hintStyle: const TextStyle(color: AppColors.textLight),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
            filled: true,
            fillColor: AppColors.offWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Save Transaction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    final recent = widget.recentTransactions.take(5).toList();
    if (recent.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Recent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                )),
            Text('See all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                )),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: recent.map((t) => _buildRecentItem(t)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentItem(Transaction t) {
    final isIncome = t.isIncome;
    final color =
        isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final bgColor =
        isIncome ? const Color(0xFFE8F7EE) : const Color(0xFFFFEBEA);
    final prefix = isIncome ? '+₱' : '-₱';
    final timeStr = DateFormat('MMM d, h:mm a').format(t.date);
    final fmt = NumberFormat('#,##0');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child:
                  Text(t.category.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )),
                Text(timeStr,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          Text(
            '$prefix${fmt.format(t.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pressable scale widget for tap animations ─────────────────────────────────

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onDelete,
    this.onEdit,
  });

  void _showOptionsSheet(BuildContext context) {
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? AppColors.incomeGreen : Colors.red.shade600;
    final fmt = NumberFormat('#,##0.00');
    final prefix = isIncome ? '+₱' : '-₱';

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isIncome ? const Color(0xFFE8F5EE) : const Color(0xFFFFDDDD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(transaction.category.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction.title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat('EEE, MMM d · h:mm a').format(transaction.date),
                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$prefix${fmt.format(transaction.amount)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: amountColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.edit_rounded,
              iconColor: AppColors.primaryGreen,
              iconBg: const Color(0xFFE8F5EE),
              label: 'Edit Transaction',
              subtitle: 'Modify amount, category, or date',
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            const SizedBox(height: 4),
            _OptionTile(
              icon: Icons.delete_rounded,
              iconColor: Colors.red.shade600,
              iconBg: const Color(0xFFFFDDDD),
              label: 'Delete Transaction',
              subtitle: 'This action cannot be undone',
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  backgroundColor: const Color.fromARGB(255, 1, 116, 20),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 255, 255, 255))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        content: Text(
          'Delete "${transaction.title}"? This cannot be undone.',
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? AppColors.incomeGreen : Colors.red.shade600;
    final bgColor = isIncome ? const Color(0xFFE8F5EE) : const Color(0xFFFFEBEA);
    final amountPrefix = isIncome ? '+₱' : '-₱';
    final typeLabel = isIncome ? 'Income' : 'Expense';
    final typeLabelColor = isIncome ? AppColors.incomeGreen : Colors.red;
    final typeBgColor = isIncome ? const Color(0xFFE8F5EE) : const Color(0xFFFFDDDD);
    final dateStr = DateFormat('MMM d, h:mm a').format(transaction.date);

    return Column(
      children: [
        Dismissible(
          key: ValueKey(transaction.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_rounded, color: Colors.red.shade600, size: 26),
                const SizedBox(height: 4),
                Text('Delete',
                    style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          confirmDismiss: (_) async {
            bool confirmed = false;
            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text('Delete Transaction?',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                content: Text(
                  'Delete "${transaction.title}"? This cannot be undone.',
                  style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.textGrey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      confirmed = true;
                      Navigator.pop(context);
                    },
                    child: const Text('Delete',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
            if (confirmed) onDelete?.call();
            return false;
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: amountColor.withOpacity(0.08),
              highlightColor: amountColor.withOpacity(0.04),
              onTap: () => _showOptionsSheet(context),
              onLongPress: () => _showOptionsSheet(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(transaction.category.emoji,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transaction.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                letterSpacing: -0.1,
                              )),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: typeBgColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(typeLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: typeLabelColor,
                                      letterSpacing: 0.3,
                                    )),
                              ),
                              const SizedBox(width: 6),
                              Text(dateStr,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.textGrey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$amountPrefix${NumberFormat('#,##0.00').format(transaction.amount)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: amountColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text('tap to manage',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textLight.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1, indent: 64, color: AppColors.divider),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: iconColor.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
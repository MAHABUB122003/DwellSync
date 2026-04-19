import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/colors.dart';
import '../../utils/format.dart' as format_utils;

class LandlordHistoryScreen extends StatelessWidget {
  const LandlordHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final historyItems = [
      {
        'type': 'bill_created',
        'title': 'Bill Created',
        'description': 'Bill #B001 for John Doe - \$1,500',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'icon': Icons.receipt_long,
        'color': AppColors.primary,
      },
      {
        'type': 'bill_paid',
        'title': 'Bill Paid',
        'description': 'Bill #B002 paid by Jane Smith - \$1,500',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'icon': Icons.check_circle,
        'color': AppColors.success,
      },
      {
        'type': 'tenant_added',
        'title': 'Tenant Added',
        'description': 'New tenant John Doe added to Unit 101',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'icon': Icons.person_add,
        'color': AppColors.primary,
      },
      {
        'type': 'bill_overdue',
        'title': 'Bill Overdue',
        'description': 'Bill #B001 is now overdue',
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'icon': Icons.error,
        'color': AppColors.error,
      },
      {
        'type': 'tenant_removed',
        'title': 'Tenant Removed',
        'description': 'Tenant moved out of Unit 102',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'icon': Icons.person_remove,
        'color': AppColors.error,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        elevation: 0,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDark = themeProvider.isDarkMode;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyItems.length,
            itemBuilder: (context, index) {
              final item = historyItems[index];
              return _HistoryCard(
                item: item,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;

  const _HistoryCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgTertiary : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.darkBgSecondary : AppColors.greyLighter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                item['icon'],
                color: item['color'],
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'],
                  style: TextStyle(
                    color:
                        isDark ? AppColors.darkTextSecondary : AppColors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  format_utils.FormatUtils.formatDateTime(item['date']),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.greyDark,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.greyDark,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/payment_provider.dart';
import '../../utils/colors.dart';
import '../../utils/format.dart' as format_utils;
import '../../widgets/custom_button.dart';

class TenantBillsScreen extends StatefulWidget {
  const TenantBillsScreen({Key? key}) : super(key: key);

  @override
  State<TenantBillsScreen> createState() => _TenantBillsScreenState();
}

class _TenantBillsScreenState extends State<TenantBillsScreen> {
  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bills'),
        elevation: 0,
      ),
      body: Consumer2<ThemeProvider, PaymentProvider>(
        builder: (context, themeProvider, paymentProvider, _) {
          final isDark = themeProvider.isDarkMode;
          final allBills = paymentProvider.getAllBills();

          final filteredBills = selectedFilter == 'all'
              ? allBills
              : allBills
                  .where((bill) => bill.status == selectedFilter)
                  .toList();

          final totalDue = filteredBills.fold(
              0.0, (sum, bill) => sum + (bill.status != 'paid' ? bill.amount : 0));

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount Due',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              format_utils.FormatUtils.formatCurrency(totalDue),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (totalDue > 0)
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                            ),
                            child: const Text(
                              'Pay Now',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: selectedFilter == 'all',
                          onTap: () => setState(() => selectedFilter = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Paid',
                          isSelected: selectedFilter == 'paid',
                          onTap: () => setState(() => selectedFilter = 'paid'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Unpaid',
                          isSelected: selectedFilter == 'unpaid',
                          onTap: () =>
                              setState(() => selectedFilter = 'unpaid'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Overdue',
                          isSelected: selectedFilter == 'overdue',
                          onTap: () =>
                              setState(() => selectedFilter = 'overdue'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bills List
                  Text(
                    'Bills (${filteredBills.length})',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  filteredBills.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 48,
                                  color: AppColors.grey.withOpacity(0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No bills found',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredBills.length,
                          itemBuilder: (context, index) {
                            final bill = filteredBills[index];
                            return _BillDetailCard(bill: bill, isDark: isDark);
                          },
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _BillDetailCard extends StatelessWidget {
  final dynamic bill;
  final bool isDark;

  const _BillDetailCard({required this.bill, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color statusColor = bill.status == 'paid'
        ? AppColors.success
        : bill.status == 'overdue'
            ? AppColors.error
            : AppColors.warning;

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bill #${bill.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format_utils.FormatUtils.formatMonthYear(bill.dueDate),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  bill.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    format_utils.FormatUtils.formatCurrency(bill.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Due Date',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    format_utils.FormatUtils.formatDate(bill.dueDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (bill.status != 'paid')
            Column(
              children: [
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Pay Now',
                  onPressed: () {},
                  height: 40,
                  fontSize: 12,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

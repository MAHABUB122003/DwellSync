import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/colors.dart';
import '../../utils/format.dart' as format_utils;
import '../../widgets/custom_button.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({Key? key}) : super(key: key);

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer3<ThemeProvider, AuthProvider, PaymentProvider>(
          builder: (context, themeProvider, authProvider, paymentProvider, _) {
            final isDark = themeProvider.isDarkMode;
            final userName = authProvider.currentUser?.name ?? 'Landlord';
            final bills = paymentProvider.getAllBills();
            final totalAmount = paymentProvider.getTotalAmount();
            final paidAmount = paymentProvider.getTotalPaidAmount();
            final unpaidAmount = paymentProvider.getTotalUnpaidAmount();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              userName,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 24),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Text(
                                format_utils.FormatUtils.getInitials(userName),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Bills',
                            value: bills.length.toString(),
                            icon: Icons.receipt_long,
                            color: AppColors.primary,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Paid',
                            value: paymentProvider.getPendingBillsCount() > 0
                                ? '${bills.where((b) => b.status == 'paid').length}'
                                : '0',
                            icon: Icons.check_circle,
                            color: AppColors.success,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Pending',
                            value: '${bills.where((b) => b.status == 'unpaid').length}',
                            icon: Icons.pending,
                            color: AppColors.warning,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Overdue',
                            value: '${bills.where((b) => b.status == 'overdue').length}',
                            icon: Icons.error,
                            color: AppColors.error,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Revenue Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Revenue Overview',
                            style:
                                Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Expected',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.grey,
                                        ),
                                  ),
                                  Text(
                                    format_utils.FormatUtils.formatCurrency(totalAmount),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          fontSize: 18,
                                          color: AppColors.primary,
                                        ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Paid: ${format_utils.FormatUtils.formatCurrency(paidAmount)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Unpaid: ${format_utils.FormatUtils.formatCurrency(unpaidAmount)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'New Bill',
                            icon: Icons.add,
                            onPressed: () =>
                                Navigator.pushNamed(context, '/create_bill'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Add Tenant',
                            icon: Icons.person_add,
                            isOutlined: true,
                            onPressed: () =>
                                Navigator.pushNamed(context, '/add_tenant'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Bills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Bills',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/landlord_bills'),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    bills.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 32),
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
                                    'No bills yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.grey,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bills.length > 5 ? 5 : bills.length,
                            itemBuilder: (context, index) {
                              final bill = bills[index];
                              return _BillCard(bill: bill, isDark: isDark);
                            },
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor:
                themeProvider.isDarkMode ? AppColors.darkBgSecondary : Colors.white,
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  break;
                case 1:
                  Navigator.pushNamed(context, '/landlord_tenants');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/landlord_bills');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/landlord_history');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Tenants'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Bills'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final dynamic bill;
  final bool isDark;

  const _BillCard({required this.bill, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color statusColor = bill.status == 'paid'
        ? AppColors.success
        : bill.status == 'overdue'
            ? AppColors.error
            : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgTertiary : Colors.white,
        border: Border.all(
          color: isDark
              ? AppColors.darkBgSecondary
              : AppColors.greyLighter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bill #${bill.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                format_utils.FormatUtils.formatCurrency(bill.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  bill.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

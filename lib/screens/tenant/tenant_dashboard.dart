import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/colors.dart';
import '../../utils/format.dart' as format_utils;
import '../../widgets/custom_button.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({Key? key}) : super(key: key);

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer3<ThemeProvider, AuthProvider, PaymentProvider>(
          builder: (context, themeProvider, authProvider, paymentProvider, _) {
            final isDark = themeProvider.isDarkMode;
            final userName = authProvider.currentUser?.name ?? 'Tenant';
            final userEmail = authProvider.currentUser?.email ?? '';
            final bills = paymentProvider.getAllBills();
            final unpaidBills =
                bills.where((b) => b.status == 'unpaid').toList();
            final overdueBills =
                bills.where((b) => b.status == 'overdue').toList();
            final totalUnpaid = unpaidBills.fold(0.0, (sum, b) => sum + b.amount);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome,',
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

                    // Alert Banner for Overdue Bills
                    if (overdueBills.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: AppColors.error,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Overdue Bills',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'You have ${overdueBills.length} overdue bill(s)',
                                    style: TextStyle(
                                      color: AppColors.error.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/tenant_bills'),
                              child: const Text('Pay Now'),
                            ),
                          ],
                        ),
                      ),
                    if (overdueBills.isNotEmpty) const SizedBox(height: 24),

                    // Quick Info Cards
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            title: 'Total Due',
                            value: format_utils.FormatUtils.formatCurrency(totalUnpaid),
                            icon: Icons.credit_card,
                            color: AppColors.error,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            title: 'Pending',
                            value: unpaidBills.length.toString(),
                            icon: Icons.pending_actions,
                            color: AppColors.warning,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            title: 'Paid Bills',
                            value: bills.where((b) => b.status == 'paid').length.toString(),
                            icon: Icons.check_circle,
                            color: AppColors.success,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            title: 'Total Bills',
                            value: bills.length.toString(),
                            icon: Icons.receipt_long,
                            color: AppColors.primary,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    CustomButton(
                      text: 'View All Bills',
                      icon: Icons.receipt_long,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/tenant_bills'),
                    ),
                    const SizedBox(height: 24),

                    // Recent Bills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                            itemCount: bills.length > 3 ? 3 : bills.length,
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
            backgroundColor: themeProvider.isDarkMode
                ? AppColors.darkBgSecondary
                : Colors.white,
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  break;
                case 1:
                  Navigator.pushNamed(context, '/tenant_bills');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/messaging');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/profile');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Bills'),
              BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _InfoCard({
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
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
          color: isDark ? AppColors.darkBgSecondary : AppColors.greyLighter,
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

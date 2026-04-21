import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/format.dart';
import 'dart:async';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _LandlordHomeScreen(),
    const _CreateBillScreen(),
    const _LandlordProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DwellSync - Landlord'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Create Bill',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _LandlordHomeScreen extends StatelessWidget {
  const _LandlordHomeScreen();

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final currentLandlordId = authProvider.currentUser?.id ?? '';
    final totalCollected = paymentProvider.getTotalCollectedForLandlord(currentLandlordId);
    final activeTenants = paymentProvider.getActiveTenantsCountForLandlord(currentLandlordId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0066CC), Color(0xFF0099FF)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0066CC).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      (authProvider.currentUser?.name ?? 'L').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${authProvider.currentUser?.name?.split(' ')[0] ?? 'Landlord'}! 👋',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage properties & income',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildStatCard(
                title: 'Total Collected',
                value: AppFormat.formatCurrency(totalCollected),
                icon: Icons.attach_money,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0FFF4), Color(0xFFE0F7E9)],
                ),
                textColor: const Color(0xFF27AE60),
              ),
              _buildStatCard(
                title: 'Bills Paid',
                value: paymentProvider.getTotalPaidBillsCountForLandlord(currentLandlordId).toString(),
                icon: Icons.done_all,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0FFFF), Color(0xFFE0F8FA)],
                ),
                textColor: const Color(0xFF16A085),
              ),
              _buildStatCard(
                title: 'Pending Bills',
                value: paymentProvider.getPendingBillsForLandlord(currentLandlordId).length.toString(),
                icon: Icons.pending_actions,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF8F0), Color(0xFFFFEBE0)],
                ),
                textColor: const Color(0xFFE67E22),
              ),
              _buildStatCard(
                title: 'Active Tenants',
                value: activeTenants.toString(),
                icon: Icons.people,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0F4FF), Color(0xFFE0EBFF)],
                ),
                textColor: const Color(0xFF2980B9),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildActionCard(
                title: 'Create Bill',
                icon: Icons.add_circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF0F0), Color(0xFFFFE0E0)],
                ),
                iconColor: const Color(0xFFE74C3C),
                onTap: () {
                  final state = context.findAncestorStateOfType<_LandlordDashboardState>();
                  if (state != null) {
                    state.setState(() {
                      state._selectedIndex = 1;
                    });
                  }
                },
              ),
              _buildActionCard(
                title: 'View Tenants',
                icon: Icons.people,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0F8FF), Color(0xFFE0EFFF)],
                ),
                iconColor: const Color(0xFF2980B9),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tenants feature coming soon!')),
                  );
                },
              ),
              _buildActionCard(
                title: 'Messages',
                icon: Icons.message,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0FFFF), Color(0xFFE0F8FA)],
                ),
                iconColor: const Color(0xFF16A085),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Messages feature coming soon!')),
                  );
                },
              ),
              _buildActionCard(
                title: 'Send Reminder',
                icon: Icons.notifications,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF8F0), Color(0xFFFFEBE0)],
                ),
                iconColor: const Color(0xFFE67E22),
                onTap: () async {
                  final tenants = paymentProvider.tenants;
                  if (tenants.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No tenants found')),
                    );
                    return;
                  }
                  
                  String? selectedTenantId;
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text('Send Reminder'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: tenants.length,
                                itemBuilder: (context, index) {
                                  final t = tenants[index];
                                  return RadioListTile<String>(
                                    title: Text(t['name'] ?? ''),
                                    subtitle: Text(t['phone'] ?? ''),
                                    value: t['id'],
                                    groupValue: selectedTenantId,
                                    onChanged: (v) {
                                      setState(() {
                                        selectedTenantId = v;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, selectedTenantId),
                                child: const Text('Send'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );

                  if (selectedTenantId != null) {
                    await paymentProvider.sendReminder(
                      selectedTenantId!,
                      'Please pay your pending rent.',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder sent successfully!')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Paid Bills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Payments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: ${paymentProvider.getTotalPaidBillsCount()}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Builder(builder: (context) {
            final currentLandlordId = authProvider.currentUser?.id ?? '';
            final recentPaidBills = paymentProvider.getRecentPaidBillsForLandlord(currentLandlordId);
            if (recentPaidBills.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.payment, color: Colors.grey, size: 40),
                        const SizedBox(height: 10),
                        const Text(
                          'No Payments Yet',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Payments from tenants will appear here',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: recentPaidBills.map((paidBill) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    title: Text(
                      paidBill['tenantName'] ?? 'Unknown Tenant',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          'Bill #${(paidBill['bill'] as dynamic).id.toString().substring(0, 8)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Paid: ${AppFormat.formatDate(paidBill['paidDate'] as DateTime)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppFormat.formatCurrency(paidBill['amount'] as double),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'PAID',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: textColor.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: textColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required LinearGradient gradient,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 36),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateBillScreen extends StatelessWidget {
  const _CreateBillScreen();

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final tenants = paymentProvider.tenants;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066CC), Color(0xFF0099FF)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Bill',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Generate bills for your tenants',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (tenants.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.person_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No Tenants Added',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add tenants to create bills',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Add Tenant',
                      onPressed: () {},
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: tenants.map((tenant) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0066CC).withOpacity(0.1),
                      child: Text(
                        (tenant['name'] ?? 'T')[0].toUpperCase(),
                        style: const TextStyle(color: Color(0xFF0066CC)),
                      ),
                    ),
                    title: Text(tenant['name'] ?? 'Unknown'),
                    subtitle: Text(tenant['email'] ?? 'No email'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bill creation feature coming soon!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                      ),
                      child: const Text('Create Bill'),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _LandlordProfileScreen extends StatelessWidget {
  const _LandlordProfileScreen();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F9FF), Color(0xFFEBF8FF)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF0066CC).withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066CC), Color(0xFF00B4FF)],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFF5F9FF),
                    child: Text(
                      user?.name.substring(0, 1) ?? 'L',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFF0066CC),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user?.name ?? 'Landlord',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066CC),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.email ?? 'No email',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFF0066CC)),
                  title: const Text('Phone'),
                  subtitle: Text(user?.phone ?? 'Not provided'),
                ),
                ListTile(
                  leading: const Icon(Icons.business, color: Color(0xFF0066CC)),
                  title: const Text('Role'),
                  subtitle: Text(user?.role.toUpperCase() ?? 'Landlord'),
                ),
                if (user?.inviteCode != null)
                  ListTile(
                    leading: const Icon(Icons.vpn_key, color: Color(0xFF0066CC)),
                    title: const Text('Invite Code'),
                    subtitle: Text(user!.inviteCode ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'Copy invite code',
                          onPressed: () {
                            final code = user.inviteCode ?? '';
                            // Copy to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invite code copied')),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              final newCode = await authProvider.regenerateInviteCode(user.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('New code: $newCode')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                          child: const Text('Regenerate'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Consumer<ThemeProvider>(
                  builder: (context, theme, child) {
                    return SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: theme.isDark,
                      onChanged: (_) => theme.toggle(),
                      secondary: const Icon(Icons.dark_mode, color: Color(0xFF0066CC)),
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Logout',
                  onPressed: () {
                    authProvider.logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
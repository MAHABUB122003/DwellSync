import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dwell_sync/models/user.dart';
import 'package:dwell_sync/providers/auth_provider.dart';
import 'package:dwell_sync/providers/payment_provider.dart';
import 'package:dwell_sync/screens/landlord/create_bill_screen.dart';
import 'package:dwell_sync/utils/colors.dart';
import 'package:dwell_sync/utils/format.dart';
import 'package:dwell_sync/providers/theme_provider.dart';
import 'package:dwell_sync/screens/landlord/view_tenants_screen.dart';
import 'package:dwell_sync/screens/messages/conversations_screen.dart';
import 'package:flutter/services.dart';
import 'package:dwell_sync/widgets/custom_button.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _LandlordHomeScreen(),
    const CreateBillScreen(),
    const _LandlordProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DwellSync - Landlord'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Create Bill'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
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

    // Get ONLY this landlord's data
    final currentLandlordId = authProvider.currentUser?.id ?? '';
    final totalCollected = paymentProvider.getTotalCollectedForLandlord(currentLandlordId);
    final activeTenants = paymentProvider.getActiveTenantsCountForLandlord(currentLandlordId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFF155E63),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${authProvider.currentUser?.name ?? 'Landlord'}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your properties and tenants',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextSecondary : Colors.white70,
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
              _buildStatCard(context,
                title: 'Total Collected',
                value: AppFormat.formatCurrency(totalCollected),
                color: Colors.green,
                icon: Icons.attach_money,
              ),
              _buildStatCard(context,
                title: 'Bills Paid',
                value: paymentProvider.getTotalPaidBillsCountForLandlord(currentLandlordId).toString(),
                color: Colors.teal,
                icon: Icons.done_all,
              ),
              _buildStatCard(context,
                title: 'Pending Bills',
                value: paymentProvider.getPendingBillsForLandlord(currentLandlordId).length.toString(),
                color: Colors.orange,
                icon: Icons.pending_actions,
              ),
              _buildStatCard(context,
                title: 'Active Tenants',
                value: activeTenants.toString(),
                color: Colors.blue,
                icon: Icons.people,
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
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateBillScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                title: 'View Tenants',
                icon: Icons.people,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ViewTenantsScreen()),
                  );
                },
              ),
              _buildActionCard(
                title: 'Messages',
                icon: Icons.message,
                color: Colors.teal,
                onTap: () {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ConversationsScreen(userId: auth.currentUser!.id, title: 'Messages')),
                  );
                },
              ),
              _buildActionCard(
                title: 'Send Reminder',
                icon: Icons.notifications,
                color: Colors.orange,
                onTap: () async {
                  // show dialog to pick tenant and send reminder
                  final messenger = ScaffoldMessenger.of(context);
                  final tenants = paymentProvider.tenants;
                  final tenantId = await showDialog<String?>(
                    context: context,
                    builder: (context) {
                      String? selected;
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
                                groupValue: selected,
                                onChanged: (v) {
                                  selected = v;
                                  // rebuild dialog
                                  (context as Element).markNeedsBuild();
                                },
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.pop(context, selected), child: const Text('Send')),
                        ],
                      );
                    },
                  );

                  if (tenantId != null) {
                    await paymentProvider.sendReminder(tenantId, 'Please pay your pending rent.');
                    if (!context.mounted) return;
                    messenger.showSnackBar(const SnackBar(content: Text('Reminder sent')));
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
                  color: Colors.green.withAlpha(25),
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
            // Get ONLY this landlord's recent paid bills
            final currentLandlordId = authProvider.currentUser?.id ?? '';
            final recentPaidBills = paymentProvider.getRecentPaidBillsForLandlord(currentLandlordId);
            if (recentPaidBills.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.payment, color: textSecondary, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          'No Payments Yet',
                          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : null),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Payments from tenants will appear here',
                          style: TextStyle(color: textSecondary, fontSize: 12),
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
                        color: Colors.green.withAlpha(25),
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
                          style: TextStyle(fontSize: 12, color: textSecondary),
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
                            color: Colors.green.withAlpha(25),
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

  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandlordProfileScreen extends StatelessWidget {
  const _LandlordProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return LandlordProfileSection(user: user);
  }
}

class LandlordProfileSection extends StatefulWidget {
  final dynamic user;
  const LandlordProfileSection({super.key, required this.user});

  @override
  State<LandlordProfileSection> createState() => _LandlordProfileSectionState();
}

class _LandlordProfileSectionState extends State<LandlordProfileSection> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  XFile? _selectedPhoto;
  Uint8List? _previewBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedPhoto = picked;
          _previewBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick photo: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        photoFile: _selectedPhoto,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      setState(() {
        _selectedPhoto = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  ImageProvider _buildProfileImage(User? user) {
    if (_previewBytes != null) return MemoryImage(_previewBytes!);
    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) return NetworkImage(user.photoUrl!);
    return const AssetImage(''); // fallback handled by CircleAvatar child
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Profile Header Card with gradient
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : AppColors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                backgroundImage: _previewBytes != null || (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                    ? _buildProfileImage(user)
                    : null,
                child: _previewBytes == null && (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                    ? Text(
                        (user?.name ?? 'L').substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Landlord',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'No email',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.business_outlined, size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'PROFESSIONAL ACCOUNT',
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Account Settings Card
        Card(
          elevation: isDark ? 0 : 2,
          color: isDark ? AppColors.darkCard : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: isDark ? AppColors.darkTextPrimary : AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Account Settings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextPrimary : AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Change Profile Photo'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                            foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      if (_selectedPhoto != null) ...[
                        const SizedBox(height: 10),
                        Text('Selected: ${_selectedPhoto!.name}', style: TextStyle(fontSize: 12, color: textSecondary)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: _saving ? 'Saving...' : 'Save Profile',
                          onPressed: _saving ? null : _saveProfile,
                          color: AppColors.secondary,
                          isLoading: _saving,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Account Details Card
        Card(
          elevation: isDark ? 0 : 2,
          color: isDark ? AppColors.darkCard : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              if (user?.inviteCode != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.vpn_key_outlined, color: isDark ? AppColors.darkTextPrimary : AppColors.secondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Invite Code', style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(user!.inviteCode ?? '', style: TextStyle(color: textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () {
                          final code = user.inviteCode ?? '';
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite code copied')));
                        },
                      ),
                    ],
                  ),
                ),
              ListTile(
                leading: Icon(Icons.phone_outlined, color: isDark ? AppColors.darkTextPrimary : AppColors.primary),
                title: const Text('Phone', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(user?.phone ?? 'Not provided', style: TextStyle(color: textSecondary)),
              ),
              if (user?.phone != null) const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.badge_outlined, color: isDark ? AppColors.darkTextPrimary : AppColors.primary),
                title: const Text('Role', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('LANDLORD', style: TextStyle(color: textSecondary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Actions Card
        Card(
          elevation: isDark ? 0 : 2,
          color: isDark ? AppColors.darkCard : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              Consumer<ThemeProvider>(builder: (context, theme, child) {
                return SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Use a darker experience for low-light sessions', style: TextStyle(color: textSecondary, fontSize: 12)),
                  value: theme.isDark,
                  onChanged: (_) => theme.toggle(),
                  secondary: Icon(Icons.dark_mode_outlined, color: isDark ? AppColors.darkTextPrimary : AppColors.secondary),
                );
              }),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.people_outline, color: isDark ? AppColors.darkTextPrimary : AppColors.secondary),
                title: const Text('Manage Tenants', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('View and organize your tenants', style: TextStyle(color: textSecondary, fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textSecondary),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewTenantsScreen()));
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout_outlined, color: isDark ? Colors.red.shade300 : AppColors.danger),
                title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Sign out of your account securely', style: TextStyle(color: textSecondary, fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textSecondary),
                onTap: () {
                  authProvider.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}


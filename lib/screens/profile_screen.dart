import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    nameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          final isDark = themeProvider.isDarkMode;
          final user = authProvider.currentUser;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Text(
                              user?.name[0] ?? 'U',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'User',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (user?.role ?? 'user').toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Information Section
                  Text(
                    'Profile Information',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Name Field
                  _ProfileField(
                    label: 'Full Name',
                    controller: nameController,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 12),

                  // Email Field
                  _ProfileField(
                    label: 'Email',
                    controller: emailController,
                    icon: Icons.email,
                    enabled: false,
                  ),
                  const SizedBox(height: 12),

                  // Phone Field
                  _ProfileField(
                    label: 'Phone Number',
                    controller: phoneController,
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 32),

                  // Settings Section
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Theme Toggle
                  _SettingTile(
                    icon: Icons.brightness_4,
                    title: 'Dark Mode',
                    subtitle: 'Toggle dark theme',
                    isDark: isDark,
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        themeProvider.setDarkMode(value);
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Notifications
                  _SettingTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Manage notifications',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  // About
                  _SettingTile(
                    icon: Icons.info,
                    title: 'About',
                    subtitle: 'About DwellSync',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  // Help & Support
                  _SettingTile(
                    icon: Icons.help,
                    title: 'Help & Support',
                    subtitle: 'Contact support',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  CustomButton(
                    text: 'Save Changes',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Changes saved')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Sign Out',
                    isOutlined: true,
                    onPressed: () {
                      authProvider.logout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/splash',
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // App Version
                  Center(
                    child: Text(
                      'DwellSync v1.0.0',
                      style: TextStyle(
                        color:
                            isDark ? AppColors.darkTextSecondary : AppColors.grey,
                        fontSize: 12,
                      ),
                    ),
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

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            trailing ?? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

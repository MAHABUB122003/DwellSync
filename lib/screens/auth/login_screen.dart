import 'package:flutter/material.dart';
import 'package:dwell_sync/utils/colors.dart';
import 'package:dwell_sync/widgets/custom_button.dart';
import 'package:dwell_sync/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isLoginSuccessful = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate login API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isLoginSuccessful = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Show success screen if login was successful
    if (_isLoginSuccessful) {
      return _buildSuccessScreen(context, isDark, size);
    }

    // Show login form
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  SizedBox(height: size.height * 0.05),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            size: 40,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back',
                          style:
                              Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your account',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.grey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),

                  // Email Field
                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    required: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                          .hasMatch(value!)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  CustomTextField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: Icons.visibility_off_outlined,
                    required: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Password is required';
                      }
                      if (value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() => _rememberMe = value ?? false);
                              },
                              activeColor: AppColors.primary,
                            ),
                            Text(
                              'Remember me',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.05),

                  // Login Button
                  CustomButton(
                    text: 'Sign In',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    icon: Icons.login,
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? AppColors.darkBgTertiary
                              : AppColors.greyLight,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? AppColors.darkBgTertiary
                              : AppColors.greyLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Options
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Sign Up as Landlord',
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register_landlord'),
                          isOutlined: true,
                          icon: Icons.home_work_outlined,
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Sign Up as Tenant',
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register_tenant'),
                          isOutlined: true,
                          icon: Icons.person_add_outlined,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  // Footer
                  Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: 'Create one',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context, bool isDark, Size size) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Success Message
              Text(
                'Login Successful!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
              ),
              const SizedBox(height: 16),

              // Email Display
              Text(
                _emailController.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.grey,
                    ),
              ),
              const SizedBox(height: 32),

              // Info Message
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'You are now logged in. Normally, you would be redirected to the dashboard, but we\'re showing you this success page as requested.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ),
              const SizedBox(height: 40),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Continue to Landlord Dashboard',
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/landlord_dashboard',
                      ),
                      icon: Icons.arrow_forward,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Continue to Tenant Dashboard',
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/tenant_dashboard',
                      ),
                      icon: Icons.arrow_forward,
                      isOutlined: true,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Back to Login',
                      onPressed: () => setState(() {
                        _isLoginSuccessful = false;
                        _emailController.clear();
                        _passwordController.clear();
                      }),
                      isOutlined: true,
                      icon: Icons.arrow_back,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

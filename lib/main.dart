import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dwell_sync/providers/theme_provider.dart';
import 'package:dwell_sync/providers/auth_provider.dart';
import 'package:dwell_sync/providers/payment_provider.dart';
import 'package:dwell_sync/screens/splash_screen.dart';
import 'package:dwell_sync/screens/auth/login_screen.dart';
import 'package:dwell_sync/screens/auth/register_landlord_screen.dart';
import 'package:dwell_sync/screens/auth/register_tenant_screen.dart';
import 'package:dwell_sync/screens/landlord/landlord_dashboard.dart';
import 'package:dwell_sync/screens/landlord/landlord_tenants_screen.dart';
import 'package:dwell_sync/screens/landlord/landlord_bills_screen.dart';
import 'package:dwell_sync/screens/landlord/landlord_history_screen.dart';
import 'package:dwell_sync/screens/tenant/tenant_dashboard.dart';
import 'package:dwell_sync/screens/tenant/tenant_bills_screen.dart';
import 'package:dwell_sync/screens/messaging_screen.dart';
import 'package:dwell_sync/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'DwellSync',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register_landlord': (context) =>
                  const RegisterLandlordScreen(),
              '/register_tenant': (context) => const RegisterTenantScreen(),
              '/landlord_dashboard': (context) => const LandlordDashboard(),
              '/landlord_tenants': (context) =>
                  const LandlordTenantsScreen(),
              '/landlord_bills': (context) =>
                  const LandlordBillsScreen(),
              '/landlord_history': (context) =>
                  const LandlordHistoryScreen(),
              '/tenant_dashboard': (context) => const TenantDashboard(),
              '/tenant_bills': (context) => const TenantBillsScreen(),
              '/messaging': (context) => const MessagingScreen(),
              '/profile': (context) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dwell_sync/providers/auth_provider.dart';
import 'package:dwell_sync/providers/payment_provider.dart';
import 'package:dwell_sync/providers/theme_provider.dart';
import 'package:dwell_sync/screens/splash_screen.dart';
import 'package:dwell_sync/screens/auth/login_screen.dart';
import 'package:dwell_sync/screens/auth/register_tenant_screen.dart';
import 'package:dwell_sync/screens/auth/register_landlord_screen.dart';
import 'package:dwell_sync/screens/landlord/create_bill_screen.dart';
import 'package:dwell_sync/screens/tenant/view_bills_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AuthProvider, PaymentProvider>(
        builder: (context, authProvider, paymentProvider, child) {
          // Connect AuthProvider to PaymentProvider so it can get real tenants
          paymentProvider.setAuthProvider(authProvider);
          
          return Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              return MaterialApp(
                title: 'DwellSync - Simple Version',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primaryColor: const Color(0xFF155E63),
                  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF155E63)),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xFF155E63),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    centerTitle: true,
                  ),
                  cardTheme: CardThemeData(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    selectedItemColor: Color(0xFF155E63),
                    unselectedItemColor: Colors.grey,
                  ),
                  scaffoldBackgroundColor: const Color(0xFFF6F8FA),
                ),
                darkTheme: ThemeData.dark(),
                themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
                home: const SplashScreen(),
                routes: {
                  '/login': (context) => const LoginScreen(),
                  '/forgot-password': (context) => const LoginScreen(),
                  '/register/tenant': (context) => const RegisterTenantScreen(),
                  '/register/landlord': (context) => const RegisterLandlordScreen(),
                  '/landlord/create-bill': (context) => const CreateBillScreen(),
                  '/tenant/bills': (context) => const ViewBillsScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}


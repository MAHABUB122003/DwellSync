import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dwell_sync/providers/theme_provider.dart';
import 'package:dwell_sync/providers/auth_provider.dart';
import 'package:dwell_sync/providers/payment_provider.dart';
import 'package:dwell_sync/screens/splash_screen.dart';
import 'package:dwell_sync/screens/auth/login_screen.dart';
import 'package:dwell_sync/screens/auth/register_landlord_screen.dart';
import 'package:dwell_sync/screens/auth/register_tenant_screen.dart';

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
            },
          );
        },
      ),
    );
  }
}



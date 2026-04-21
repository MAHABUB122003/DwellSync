import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_tenant_screen.dart';
import 'screens/register_landlord_screen.dart';

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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'DwellSync',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register/tenant': (context) => const RegisterTenantScreen(),
              '/register/landlord': (context) => const RegisterLandlordScreen(),
            },
          );
        },
      ),
    );
  }
}
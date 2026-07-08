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
import 'package:dwell_sync/utils/colors.dart';

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
          paymentProvider.setAuthProvider(authProvider);

          return Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              return MaterialApp(
                title: 'DwellSync',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  primaryColor: AppColors.primary,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.primary,
                    secondary: AppColors.secondary,
                    brightness: Brightness.light,
                  ),
                  scaffoldBackgroundColor: AppColors.background,
                  appBarTheme: AppBarTheme(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    centerTitle: true,
                    titleTextStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  cardTheme: CardThemeData(
                    color: AppColors.card,
                    elevation: 2,
                    shadowColor: AppColors.shadow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    backgroundColor: AppColors.card,
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: AppColors.textSecondary,
                    elevation: 0,
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: AppColors.card,
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary, width: 1.6),
                    ),
                  ),
                  dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
                  snackBarTheme: SnackBarThemeData(
                    backgroundColor: AppColors.textPrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.dark,
                  colorScheme: ColorScheme.dark(
                    primary: AppColors.primary,
                    secondary: AppColors.secondary,
                    surface: AppColors.darkCard,
                  ),
                  scaffoldBackgroundColor: AppColors.darkBackground,
                  appBarTheme: AppBarTheme(
                    backgroundColor: AppColors.darkSurface,
                    foregroundColor: AppColors.darkTextPrimary,
                    elevation: 0,
                    centerTitle: true,
                    titleTextStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextPrimary,
                    ),
                    iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
                  ),
                  cardTheme: CardThemeData(
                    color: AppColors.darkCard,
                    elevation: 1,
                    shadowColor: AppColors.darkShadow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    backgroundColor: AppColors.darkCard,
                    selectedItemColor: AppColors.secondary,
                    unselectedItemColor: AppColors.darkTextSecondary,
                    elevation: 0,
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: AppColors.darkSurface,
                    hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
                    labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.darkBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary, width: 1.6),
                    ),
                  ),
                  dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 1),
                  snackBarTheme: SnackBarThemeData(
                    backgroundColor: AppColors.darkSurface,
                    contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  textTheme: const TextTheme(
                    bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
                    bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
                    bodySmall: TextStyle(color: AppColors.darkTextSecondary),
                    titleLarge: TextStyle(color: AppColors.darkTextPrimary),
                    titleMedium: TextStyle(color: AppColors.darkTextPrimary),
                    titleSmall: TextStyle(color: AppColors.darkTextPrimary),
                  ),
                ),
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


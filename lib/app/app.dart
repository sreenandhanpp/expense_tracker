import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.init();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Spendo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.textPrimary,
          surface: AppColors.surface,
          primary: AppColors.textPrimary,
        ),
        fontFamily: 'Roboto',
      ),
      home: ListenableBuilder(
        listenable: _authService,
        builder: (context, _) {
          if (!_authService.isInitialized) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }

          if (!_authService.isAuthenticated) {
            return const LoginScreen();
          }

          return const MainNavigationScreen();
        },
      ),
    );
  }
}

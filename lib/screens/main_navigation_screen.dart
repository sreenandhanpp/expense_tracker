import 'package:flutter/material.dart';
import '../data/expense_repository.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import 'home_screen.dart';
import 'transactions_screen.dart';
import 'insights_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final ExpenseRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = ExpenseRepository();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        repository: _repository,
        onSearchPressed: () => setState(() => _currentIndex = 1),
        onFilterPressed: () => setState(() => _currentIndex = 1),
      ),
      TransactionsScreen(
        repository: _repository,
      ),
      InsightsScreen(
        repository: _repository,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.surface,
          elevation: 0,
          selectedItemColor: AppColors.textPrimary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Trends',
            ),
          ],
        ),
      ),
    );
  }
}

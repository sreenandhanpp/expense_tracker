import 'package:flutter/material.dart';
import '../data/expense_repository.dart';
import '../models/expense.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';
import '../utils/date_formatter.dart';
import '../widgets/spending_summary_card.dart';
import '../widgets/expense_tile.dart';
import '../widgets/empty_state.dart';
import 'add_expense_screen.dart';
import 'expense_detail_sheet.dart';

class HomeScreen extends StatelessWidget {
  final ExpenseRepository repository;
  final VoidCallback onSearchPressed;
  final VoidCallback onFilterPressed;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.onSearchPressed,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final allExpenses = repository.expenses;
        final totalSpending = repository.totalSpendingThisWeek;
        final dailyTotals = repository.weeklyDailyTotals;

        final Map<String, List<Expense>> groupedExpenses = {};
        if (allExpenses.isNotEmpty) {
          final recentGroup = allExpenses.take(2).toList();
          groupedExpenses['Latest'] = recentGroup;

          final remaining = allExpenses.skip(2).toList();
          for (var exp in remaining) {
            final header = DateFormatter.formatGroupHeader(exp.date);
            groupedExpenses.putIfAbsent(header, () => []).add(exp);
          }
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top Header Pill Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      top: AppSpacing.md,
                      bottom: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        // Personal Pill Selector
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Personal',
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.unfold_more,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Top Subtle Icons (Search, Filter)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search, size: 20, color: AppColors.textPrimary),
                                onPressed: onSearchPressed,
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.filter_list, size: 20, color: AppColors.textPrimary),
                                onPressed: onFilterPressed,
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content Body
                if (allExpenses.isEmpty)
                  SliverFillRemaining(
                    child: EmptyStateWidget(
                      onAddPressed: () => _navigateToAddExpense(context),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Total Spending Summary Card with Bar Chart
                        SpendingSummaryCard(
                          totalSpending: totalSpending,
                          dailyTotals: dailyTotals,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Grouped Expense Lists
                        for (var entry in groupedExpenses.entries)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 8),
                                child: Text(
                                  entry.key,
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // White Card wrapping the expense group
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  children: entry.value.asMap().entries.map((item) {
                                    final index = item.key;
                                    final expense = item.value;
                                    final isLast = index == entry.value.length - 1;

                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          child: ExpenseTile(
                                            expense: expense,
                                            showCategorySubtitle: false,
                                            onTap: () {
                                              ExpenseDetailSheet.show(
                                                context,
                                                expense: expense,
                                                onDelete: () => repository.deleteExpense(expense.id),
                                                onUpdate: (updated) => repository.updateExpense(updated),
                                              );
                                            },
                                          ),
                                        ),
                                        if (!isLast)
                                          const Divider(
                                            height: 1,
                                            indent: 64,
                                            color: AppColors.divider,
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ),

                        const SizedBox(height: 60),
                      ]),
                    ),
                  ),
              ],
            ),
          ),

          // Primary Circular Black FAB '+'
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToAddExpense(context),
            backgroundColor: AppColors.primary,
            elevation: 2,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add,
              size: 28,
              color: AppColors.surface,
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToAddExpense(BuildContext context) async {
    final newExpense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
      ),
    );
    if (newExpense != null) {
      repository.addExpense(newExpense);
    }
  }
}

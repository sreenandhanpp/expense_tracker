import 'package:flutter/material.dart';
import '../data/expense_repository.dart';
import '../models/expense.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';
import '../utils/date_formatter.dart';
import '../widgets/expense_tile.dart';
import '../widgets/empty_state.dart';
import 'add_expense_screen.dart';
import 'expense_detail_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  final ExpenseRepository repository;

  const TransactionsScreen({
    super.key,
    required this.repository,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ExpenseCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final query = _searchController.text.trim();
        final filteredList = widget.repository.search(query, _selectedCategory);

        // Group by relative date string
        final Map<String, List<Expense>> grouped = {};
        for (var exp in filteredList) {
          final key = DateFormatter.formatGroupHeader(exp.date);
          grouped.putIfAbsent(key, () => []).add(exp);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Title & Search Row
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    top: AppSpacing.md,
                    bottom: AppSpacing.xs,
                  ),
                  child: Text(
                    'Transactions',
                    style: AppTypography.titleLarge.copyWith(fontSize: 24),
                  ),
                ),

                // Search Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      _buildFilterChip('All', null),
                      const SizedBox(width: 8),
                      for (var cat in ExpenseCategory.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(cat.label, cat),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Transaction Group List or Empty State
                Expanded(
                  child: filteredList.isEmpty
                      ? EmptyStateWidget(
                          onAddPressed: () async {
                            final newExp = await Navigator.push<Expense>(
                              context,
                              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                            );
                            if (newExp != null) {
                              widget.repository.addExpense(newExp);
                            }
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          itemCount: grouped.entries.length,
                          itemBuilder: (context, groupIndex) {
                            final entry = grouped.entries.elementAt(groupIndex);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
                                  child: Text(
                                    entry.key.toUpperCase(),
                                    style: AppTypography.labelSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
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
                                              showCategorySubtitle: true,
                                              onTap: () {
                                                ExpenseDetailSheet.show(
                                                  context,
                                                  expense: expense,
                                                  onDelete: () => widget.repository.deleteExpense(expense.id),
                                                  onUpdate: (updated) => widget.repository.updateExpense(updated),
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
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, ExpenseCategory? category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? AppColors.surface : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

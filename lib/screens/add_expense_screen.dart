import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import '../utils/date_formatter.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/payment_picker_sheet.dart';
import '../widgets/smart_suggestion_card.dart';
import '../data/mock_expenses.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? editingExpense;

  const AddExpenseScreen({
    super.key,
    this.editingExpense,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  ExpenseCategory? _selectedCategory;
  PaymentMethod? _selectedPayment;
  late DateTime _selectedDate;
  List<Expense> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editingExpense?.title ?? '');
    _amountController = TextEditingController(
      text: widget.editingExpense != null ? widget.editingExpense!.amount.toStringAsFixed(2) : '',
    );
    _selectedCategory = widget.editingExpense?.category;
    _selectedPayment = widget.editingExpense?.paymentMethod;
    _selectedDate = widget.editingExpense?.date ?? DateTime.now();

    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onTitleChanged() async {
    final query = _titleController.text.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
      return;
    }

    List<Expense> matched = [];
    try {
      final apiSuggestions = await ApiService().getSuggestions(query);
      if (apiSuggestions.isNotEmpty) {
        matched = apiSuggestions.map((s) => s.toExpense()).toList();
      }
    } catch (_) {}

    if (matched.isEmpty) {
      matched = smartSuggestionTemplates.where((template) {
        return template.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    if (mounted) {
      setState(() {
        _suggestions = matched;
        _showSuggestions = matched.isNotEmpty;
      });
    }
  }

  void _applySuggestion(Expense template) {
    setState(() {
      _titleController.text = template.title;
      _amountController.text = template.amount.toStringAsFixed(2);
      _selectedCategory = template.category;
      _selectedPayment = template.paymentMethod;
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.textPrimary,
              onPrimary: AppColors.surface,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveExpense() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final expense = Expense(
      id: widget.editingExpense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: _selectedCategory ?? ExpenseCategory.other,
      paymentMethod: _selectedPayment ?? PaymentMethod.card,
      date: _selectedDate,
    );

    Navigator.pop(context, expense);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingExpense != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Top Drag indicator bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Bar: Cancel | New Expense | ✓ Check
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTypography.button.copyWith(fontSize: 14),
                    ),
                  ),

                  Text(
                    isEditing ? 'Edit Expense' : 'New Expense',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),

                  GestureDetector(
                    onTap: _saveExpense,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Vertically Stacked Form Container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Title Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _titleController,
                        style: AppTypography.titleMedium.copyWith(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Title',
                          hintStyle: AppTypography.titleMedium.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const Divider(height: 1, color: AppColors.divider),

                    // Smart Suggestions Overlay Card if typing title
                    if (_showSuggestions)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SmartSuggestionCard(
                          suggestions: _suggestions,
                          onSelect: _applySuggestion,
                        ),
                      ),

                    // Amount Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text(
                            'Amount',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '₹',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.right,
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                hintStyle: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: AppColors.divider),

                    // Category Selector Row
                    InkWell(
                      onTap: () async {
                        final cat = await CategoryPickerSheet.show(context, _selectedCategory);
                        if (cat != null) {
                          setState(() => _selectedCategory = cat);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              'Category',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _selectedCategory?.label ?? 'None',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.unfold_more,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 1, color: AppColors.divider),

                    // Payment Selector Row
                    InkWell(
                      onTap: () async {
                        final method = await PaymentPickerSheet.show(context, _selectedPayment);
                        if (method != null) {
                          setState(() => _selectedPayment = method);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              'Payment',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _selectedPayment?.label ?? 'None',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.unfold_more,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 1, color: AppColors.divider),

                    // Date Selector Row
                    InkWell(
                      onTap: _pickDate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Text(
                              'Date',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                DateFormatter.formatShort(_selectedDate),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

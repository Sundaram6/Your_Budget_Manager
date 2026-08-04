import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../models/recurring_transaction.dart';
import '../../repositories/recurring_repository.dart';

class CreateRecurringScreen extends StatefulWidget {
  const CreateRecurringScreen({super.key});

  @override
  State<CreateRecurringScreen> createState() => _CreateRecurringScreenState();
}

class _CreateRecurringScreenState extends State<CreateRecurringScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _intervalDaysController = TextEditingController(text: '30');
  final _notesController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedCategory = 'cat_utilities';
  String _selectedFrequency = 'monthly';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _hasNoEndDate = true;
  bool _autoConfirm = false;
  bool _isSaving = false;

  static const _categories = [
    MapEntry('cat_groceries', 'Groceries'),
    MapEntry('cat_food', 'Food & Dining'),
    MapEntry('cat_transport', 'Transport'),
    MapEntry('cat_shopping', 'Shopping'),
    MapEntry('cat_utilities', 'Utilities & Bills'),
    MapEntry('cat_entertainment', 'Entertainment'),
    MapEntry('cat_health', 'Health & Medical'),
    MapEntry('cat_income', 'Income'),
    MapEntry('cat_misc', 'Miscellaneous'),
  ];

  static const _frequencies = [
    MapEntry('daily', 'Daily'),
    MapEntry('weekly', 'Weekly'),
    MapEntry('biweekly', 'Bi-weekly'),
    MapEntry('monthly', 'Monthly'),
    MapEntry('yearly', 'Yearly'),
    MapEntry('custom', 'Custom'),
  ];

  // Quick Templates
  static const _templates = [
    {'label': '🏠 Rent', 'title': 'Monthly Rent', 'category': 'cat_utilities', 'type': 'expense', 'frequency': 'monthly'},
    {'label': '🏦 EMI', 'title': 'Loan EMI', 'category': 'cat_misc', 'type': 'expense', 'frequency': 'monthly'},
    {'label': '🎬 Netflix', 'title': 'Subscription', 'category': 'cat_entertainment', 'type': 'expense', 'frequency': 'monthly'},
    {'label': '📈 SIP', 'title': 'Monthly SIP', 'category': 'cat_misc', 'type': 'expense', 'frequency': 'monthly'},
    {'label': '📱 Recharge', 'title': 'Mobile Recharge', 'category': 'cat_utilities', 'type': 'expense', 'frequency': 'monthly'},
  ];

  void _applyTemplate(Map<String, dynamic> template) {
    setState(() {
      _titleController.text = template['title'] as String;
      _selectedCategory = template['category'] as String;
      _selectedType = template['type'] as String;
      _selectedFrequency = template['frequency'] as String;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _intervalDaysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: AppColors.darkSurface2,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: AppColors.darkSurface2,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _hasNoEndDate = false;
      });
    }
  }

  Future<void> _saveRecurringTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amountDouble = double.tryParse(_amountController.text.trim());
    if (amountDouble == null || amountDouble <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than zero')),
      );
      return;
    }

    int? intervalDays;
    if (_selectedFrequency == 'custom') {
      intervalDays = int.tryParse(_intervalDaysController.text.trim());
      if (intervalDays == null || intervalDays <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid interval in days')),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();
    final amountPaise = (amountDouble * 100).round();
    final uuid = const Uuid();
    final id = 'rec_${uuid.v4()}';

    final recurringItem = RecurringTransactionModel(
      id: id,
      title: _titleController.text.trim(),
      amountPaise: amountPaise,
      categoryId: _selectedCategory,
      type: _selectedType,
      frequency: _selectedFrequency,
      intervalDays: intervalDays,
      startDate: _startDate,
      endDate: _hasNoEndDate ? null : _endDate,
      nextDueDate: _startDate,
      lastGeneratedDate: null,
      isActive: true,
      autoConfirm: _autoConfirm,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    try {
      await RecurringRepository.instance.insert(recurringItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recurring transaction created')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String labelText, {String? hintText, String? prefixText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
      labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
      hintStyle: const TextStyle(color: AppColors.darkTextTertiary),
      filled: true,
      fillColor: AppColors.darkSurface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorderGlass),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorderGlass),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4AF37)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Add Recurring',
          style: TextStyle(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            // ── Quick Templates ──
            const Text(
              'QUICK TEMPLATES',
              style: TextStyle(
                color: AppColors.darkTextTertiary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _templates.map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        t['label'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: AppColors.darkSurface2,
                      side: const BorderSide(color: Color(0x55D4AF37)),
                      onPressed: () => _applyTemplate(t),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),

            // Type Segmented Control
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'expense'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedType == 'expense'
                              ? const Color(0xFFD4AF37)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            color: _selectedType == 'expense' ? Colors.black : AppColors.darkTextSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'income'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedType == 'income'
                              ? const Color(0xFFD4AF37)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: _selectedType == 'income' ? Colors.black : AppColors.darkTextSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space4),

            // Title Field
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Title', hintText: 'e.g. Netflix, Rent, Salary'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space3),

            // Amount Field
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Amount', hintText: '0.00', prefixText: '₹ '),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an amount';
                }
                final val = double.tryParse(value.trim());
                if (val == null || val <= 0) {
                  return 'Amount must be greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.space3),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: AppColors.darkSurface2,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Category'),
              items: _categories.map((c) {
                return DropdownMenuItem<String>(
                  value: c.key,
                  child: Text(c.value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCategory = val);
                }
              },
            ),
            const SizedBox(height: AppSpacing.space3),

            // Frequency Dropdown
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              dropdownColor: AppColors.darkSurface2,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Frequency'),
              items: _frequencies.map((f) {
                return DropdownMenuItem<String>(
                  value: f.key,
                  child: Text(f.value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedFrequency = val);
                }
              },
            ),
            const SizedBox(height: AppSpacing.space3),

            // Custom Interval Days if frequency == 'custom'
            if (_selectedFrequency == 'custom') ...[
              TextFormField(
                controller: _intervalDaysController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Interval Days', hintText: 'e.g. 10, 45'),
                validator: (value) {
                  if (_selectedFrequency == 'custom') {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter interval days';
                    }
                    final val = int.tryParse(value.trim());
                    if (val == null || val <= 0) {
                      return 'Interval days must be > 0';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space3),
            ],

            // Start Date Picker
            InkWell(
              onTap: _selectStartDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: _inputDecoration('Start Date'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(_startDate),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xFFD4AF37), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),

            // End Date Picker & No End Date Checkbox
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _hasNoEndDate ? null : _selectEndDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: _inputDecoration('End Date (Optional)'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _hasNoEndDate || _endDate == null
                                ? 'No End Date'
                                : dateFormat.format(_endDate!),
                            style: TextStyle(
                              color: _hasNoEndDate ? AppColors.darkTextTertiary : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Icons.calendar_month,
                            color: _hasNoEndDate ? AppColors.darkTextTertiary : const Color(0xFFD4AF37),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'No End Date',
                style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
              ),
              value: _hasNoEndDate,
              activeColor: const Color(0xFFD4AF37),
              checkColor: Colors.black,
              onChanged: (val) {
                setState(() {
                  _hasNoEndDate = val ?? true;
                  if (_hasNoEndDate) {
                    _endDate = null;
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.space2),

            // Auto-confirm Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Auto-add to budget without asking',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Automatically create transactions when due',
                style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
              ),
              value: _autoConfirm,
              activeColor: const Color(0xFFD4AF37),
              onChanged: (val) {
                setState(() => _autoConfirm = val);
              },
            ),
            const SizedBox(height: AppSpacing.space3),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Notes (Optional)', hintText: 'Add extra details...'),
            ),
            const SizedBox(height: AppSpacing.space6),

            // Save Button
            PrimaryButton(
              onPressed: _saveRecurringTransaction,
              label: 'Save Recurring Transaction',
              isLoading: _isSaving,
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
        ),
      ),
    );
  }
}

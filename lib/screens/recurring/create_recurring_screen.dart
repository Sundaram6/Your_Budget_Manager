import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_custom_tokens.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/inputs/numeric_keypad.dart';
import '../../features/transactions/presentation/widgets/category_picker.dart';
import '../../models/recurring_transaction.dart';
import '../../repositories/recurring_repository.dart';

class CreateRecurringScreen extends StatefulWidget {
  final RecurringTransactionModel? initialRecurring;

  const CreateRecurringScreen({super.key, this.initialRecurring});

  @override
  State<CreateRecurringScreen> createState() => _CreateRecurringScreenState();
}

class _CreateRecurringScreenState extends State<CreateRecurringScreen> {
  final _titleController = TextEditingController();
  final _intervalDaysController = TextEditingController(text: '30');
  final _notesController = TextEditingController();

  String _amountStr = '0';
  String _selectedType = 'expense';
  String _selectedCategory = 'cat_utilities';
  String _selectedFrequency = 'monthly';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _hasNoEndDate = true;
  bool _autoConfirm = false;
  bool _isSaving = false;

  bool get _isEdit => widget.initialRecurring != null;

  @override
  void initState() {
    super.initState();
    final item = widget.initialRecurring;
    if (item != null) {
      _titleController.text = item.title;
      final rupees = item.amountPaise / 100.0;
      _amountStr = rupees % 1 == 0 ? rupees.toStringAsFixed(0) : rupees.toStringAsFixed(2);
      _selectedType = item.type;
      _selectedCategory = item.categoryId;
      _selectedFrequency = item.frequency;
      if (item.intervalDays != null) {
        _intervalDaysController.text = item.intervalDays.toString();
      }
      _startDate = item.startDate;
      _endDate = item.endDate;
      _hasNoEndDate = item.endDate == null;
      _autoConfirm = item.autoConfirm;
      if (item.notes != null) {
        _notesController.text = item.notes!;
      }
    }
  }

  static const _frequencies = [
    MapEntry('daily', 'Daily'),
    MapEntry('weekly', 'Weekly'),
    MapEntry('biweekly', 'Bi-weekly'),
    MapEntry('monthly', 'Monthly'),
    MapEntry('yearly', 'Yearly'),
    MapEntry('custom', 'Custom'),
  ];

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

  void _onKeyPressed(String key) {
    setState(() {
      if (_amountStr == '0' && key != '.') {
        _amountStr = key;
      } else {
        if (key == '.' && _amountStr.contains('.')) return;
        if (_amountStr.contains('.')) {
          final parts = _amountStr.split('.');
          if (parts.length > 1 && parts[1].length >= 2) return;
        }
        _amountStr += key;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountStr.length > 1) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else {
        _amountStr = '0';
      }
    });
  }

  Future<void> _saveRecurringTransaction() async {
    final amountDouble = double.tryParse(_amountStr);
    if (amountDouble == null || amountDouble <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
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

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final amountPaise = (amountDouble * 100).round();
    final uuid = const Uuid();
    final id = _isEdit ? widget.initialRecurring!.id : 'rec_${uuid.v4()}';

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
      nextDueDate: _isEdit ? widget.initialRecurring!.nextDueDate : _startDate,
      lastGeneratedDate: _isEdit ? widget.initialRecurring!.lastGeneratedDate : null,
      isActive: _isEdit ? widget.initialRecurring!.isActive : true,
      autoConfirm: _autoConfirm,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: _isEdit ? widget.initialRecurring!.createdAt : now,
      updatedAt: now,
    );

    try {
      if (_isEdit) {
        await RecurringRepository.instance.update(recurringItem);
      } else {
        await RecurringRepository.instance.insert(recurringItem);
      }
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          // In test environments or when pushed as root, just reset saving state.
          setState(() => _isSaving = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppCustomTokens>()!;
    final dateFormat = DateFormat('yyyy-MM-dd');

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEdit ? 'Edit Recurring Payment' : 'Add Recurring',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                  child: Column(
                    children: [
                      // Pill Toggles
                      _buildPillToggles(context, tokens),
                      const SizedBox(height: AppSpacing.space6),

                      // Amount Display
                      Text(
                        '₹$_amountStr',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _selectedType == 'expense' 
                            ? theme.colorScheme.onSurface 
                            : tokens.accentSavings,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space6),

                      // Title
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
                        ),
                        child: TextField(
                          controller: _titleController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          decoration: InputDecoration(
                            hintText: 'Title (e.g. Netflix, Rent)',
                            border: InputBorder.none,
                            icon: Icon(Icons.title, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.space4),
                    
                    // Quick Templates
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _templates.map((t) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(
                                t['label'] as String,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.surface,
                              side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                              onPressed: () => _applyTemplate(t),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),

                    // Category Picker
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Category',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    CategoryPicker(
                      selectedCategoryId: _selectedCategory,
                      onCategorySelected: (val) => setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: AppSpacing.space4),

                    // Frequency
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFrequency,
                          dropdownColor: theme.colorScheme.surface,
                          isExpanded: true,
                          items: _frequencies.map((f) {
                            return DropdownMenuItem<String>(
                              value: f.key,
                              child: Text(f.value),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedFrequency = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),

                    if (_selectedFrequency == 'custom') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
                        ),
                        child: TextField(
                          controller: _intervalDaysController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          decoration: InputDecoration(
                            hintText: 'Interval Days (e.g. 10)',
                            border: InputBorder.none,
                            icon: Icon(Icons.repeat, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                    ],

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) setState(() => _startDate = d);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.space3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Start Date', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                                  const SizedBox(height: 4),
                                  Text(dateFormat.format(_startDate), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: InkWell(
                            onTap: _hasNoEndDate ? null : () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
                                firstDate: _startDate,
                                lastDate: DateTime(2100),
                              );
                              if (d != null) setState(() => _endDate = d);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.space3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('End Date', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                                  const SizedBox(height: 4),
                                  Text(
                                    _hasNoEndDate || _endDate == null ? 'No End Date' : dateFormat.format(_endDate!),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _hasNoEndDate ? theme.colorScheme.onSurface.withOpacity(0.3) : theme.colorScheme.onSurface,
                                    ),
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
                      title: const Text('No End Date'),
                      value: _hasNoEndDate,
                      activeColor: tokens.accentTransport,
                      onChanged: (val) {
                        setState(() {
                          _hasNoEndDate = val ?? true;
                          if (_hasNoEndDate) _endDate = null;
                        });
                      },
                    ),

                    // Auto-confirm Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto-add to budget'),
                      subtitle: const Text('Automatically create transactions when due'),
                      value: _autoConfirm,
                      activeColor: tokens.accentTransport,
                      onChanged: (val) => setState(() => _autoConfirm = val),
                    ),
                    const SizedBox(height: AppSpacing.space6),
                  ],
                ),
              ),
            ),
            
            // Numeric Keypad at bottom (hidden when software keyboard is open to avoid covering form)
            if (!isKeyboardOpen)
              Container(
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: _isSaving
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ))
                    : NumericKeypad(
                        onKeyPressed: _onKeyPressed,
                        onBackspace: _onBackspace,
                        onSubmit: _saveRecurringTransaction,
                        submitLabel: _isEdit ? 'Update Recurring' : 'Save Recurring',
                      ),
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildPillToggles(BuildContext context, AppCustomTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = 'expense'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'expense' ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Expense',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _selectedType == 'expense' ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                  color: _selectedType == 'income' ? tokens.accentSavings : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Income',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _selectedType == 'income' ? tokens.heroTextColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

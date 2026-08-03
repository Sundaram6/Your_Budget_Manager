import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../engines/budget/budget_engine_provider.dart';
import '../../../../engines/savings/savings_engine_provider.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Page 2 State
  final _budgetController = TextEditingController();

  // Page 3 State
  final _goalNameController = TextEditingController();
  final _goalAmountController = TextEditingController();

  // Page 4 State
  bool _smsAutoTrack = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _budgetController.dispose();
    _goalNameController.dispose();
    _goalAmountController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
      if (mounted) {
        context.go('/');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBudgetAndNext() async {
    final text = _budgetController.text.trim();
    final rupees = double.tryParse(text) ?? 0.0;
    if (rupees > 0) {
      final now = DateTime.now();
      final engine = ref.read(budgetEngineProvider);
      await engine.setMonthlyBudget(
        amountPaise: (rupees * 100).round(),
        month: now.month,
        year: now.year,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Monthly budget set to ₹${rupees.toStringAsFixed(0)}!')),
        );
      }
    }
    _nextPage();
  }

  Future<void> _saveGoalAndNext() async {
    final name = _goalNameController.text.trim();
    final amountText = _goalAmountController.text.trim();
    final rupees = double.tryParse(amountText) ?? 0.0;

    if (name.isNotEmpty && rupees > 0) {
      final engine = ref.read(savingsEngineProvider);
      await engine.createGoal(
        name: name,
        targetAmountPaise: (rupees * 100).round(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Savings Goal "$name" created!')),
        );
      }
    }
    _nextPage();
  }

  Future<void> _toggleSmsPermission(bool value) async {
    if (value) {
      final status = await Permission.sms.request();
      if (status.isGranted) {
        setState(() => _smsAutoTrack = true);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('autoTrackNewSms', true);
      } else {
        setState(() => _smsAutoTrack = false);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('SMS Permission Required'),
              content: const Text('SMS permission is required to automatically detect expenses from bank alerts.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } else {
      setState(() => _smsAutoTrack = false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoTrackNewSms', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text(
              'Skip Setup',
              style: TextStyle(color: AppColors.darkGoldPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    children: [
                      _buildPage1Welcome(),
                      _buildPage2Budget(),
                      _buildPage3SavingsGoal(),
                      _buildPage4SmsAutoTrack(),
                    ],
                  ),
                ),

                // Progress Dots Indicator & Step Counter
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.darkGoldPrimary : AppColors.darkSurface3,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Step ${_currentPage + 1} of 4',
                        style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // PAGE 1 — Welcome
  Widget _buildPage1Welcome() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 80, color: AppColors.darkGoldPrimary),
          const SizedBox(height: AppSpacing.space6),
          Text(
            'Take control of your money',
            style: AppTypography.heading1.copyWith(color: AppColors.darkTextPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            'Set your budget, track expenses, and save smarter.',
            style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space6),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGoldPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _nextPage,
              child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 2 — Monthly Budget
  Widget _buildPage2Budget() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calculate_outlined, size: 64, color: AppColors.darkGoldPrimary),
          const SizedBox(height: AppSpacing.space4),
          Text(
            'What\'s your monthly budget?',
            style: AppTypography.heading2.copyWith(color: AppColors.darkTextPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'We\'ll help you stay within your limits.',
            style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space6),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Monthly Budget Amount',
              prefixText: '₹ ',
              prefixStyle: const TextStyle(color: AppColors.darkGoldPrimary, fontSize: 20, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGoldPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveBudgetAndNext,
              child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          TextButton(
            onPressed: _nextPage,
            child: const Text('Skip for now', style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
        ],
      ),
    );
  }

  // PAGE 3 — Savings Goal
  Widget _buildPage3SavingsGoal() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.savings_outlined, size: 64, color: AppColors.darkGoldPrimary),
          const SizedBox(height: AppSpacing.space4),
          Text(
            'Want to start saving?',
            style: AppTypography.heading2.copyWith(color: AppColors.darkTextPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Even small goals build big futures.',
            style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space4),
          TextField(
            controller: _goalNameController,
            style: const TextStyle(color: AppColors.darkTextPrimary),
            decoration: InputDecoration(
              labelText: 'Goal Name',
              hintText: 'e.g. Emergency Fund',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          TextField(
            controller: _goalAmountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.darkTextPrimary),
            decoration: InputDecoration(
              labelText: 'Target Amount (₹)',
              prefixText: '₹ ',
              prefixStyle: const TextStyle(color: AppColors.darkGoldPrimary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGoldPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveGoalAndNext,
              child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          TextButton(
            onPressed: _nextPage,
            child: const Text('Skip for now', style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
        ],
      ),
    );
  }

  // PAGE 4 — SMS Auto-Tracking
  Widget _buildPage4SmsAutoTrack() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sms_outlined, size: 64, color: AppColors.darkGoldPrimary),
          const SizedBox(height: AppSpacing.space4),
          Text(
            'Auto-track expenses from SMS',
            style: AppTypography.heading2.copyWith(color: AppColors.darkTextPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'We\'ll scan your messages for Swiggy, Uber, Amazon, and bank alerts.',
            style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space6),
          SwitchListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.darkSurface3),
            ),
            tileColor: AppColors.darkSurface2,
            activeThumbColor: AppColors.darkGoldPrimary,
            title: const Text('Enable SMS Auto-Tracking'),
            subtitle: const Text('Reads transaction SMS locally on device'),
            value: _smsAutoTrack,
            onChanged: _toggleSmsPermission,
          ),
          const SizedBox(height: AppSpacing.space6),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGoldPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _finishOnboarding,
              child: const Text('Finish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text('Skip', style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
        ],
      ),
    );
  }
}

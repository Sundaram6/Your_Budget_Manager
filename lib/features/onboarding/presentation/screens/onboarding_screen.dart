import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/category_setup_page.dart';
import '../widgets/feature_highlight_page.dart';
import '../widgets/privacy_promise_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _nextPage() {
    if (_pageController.page == 2) {
      ref.read(onboardingControllerProvider.notifier).completeOnboarding().then((_) {
        if (mounted) {
          context.goNamed(RouteNames.pinSetup);
        }
      });
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Only navigate via buttons
        children: [
          PrivacyPromisePage(onNext: _nextPage),
          FeatureHighlightPage(onNext: _nextPage),
          CategorySetupPage(onNext: _nextPage),
        ],
      ),
    );
  }
}

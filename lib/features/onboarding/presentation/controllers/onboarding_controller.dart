import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_controller.g.dart';

@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  FutureOr<void> build() {}

  Future<void> completeOnboarding() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      await prefs.setBool('onboarding_complete', true);
      await prefs.setInt('onboardingCompletedAt', DateTime.now().millisecondsSinceEpoch);
      await prefs.reload();
    });
  }

  Future<void> resetOnboarding() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', false);
      await prefs.setBool('onboarding_complete', false);
      await prefs.remove('onboardingCompletedAt');
      await prefs.reload();
    });
  }
}

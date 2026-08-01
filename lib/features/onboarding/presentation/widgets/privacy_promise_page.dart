import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PrivacyPromisePage extends StatelessWidget {
  final VoidCallback onNext;
  
  const PrivacyPromisePage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.amber, // Gold color
              ).animate()
                .fadeIn(duration: 800.ms)
                .scale(delay: 200.ms)
                .shimmer(delay: 800.ms, duration: 1.seconds),
              const SizedBox(height: 32),
              Text(
                'Your money is yours.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
              const SizedBox(height: 16),
              Text(
                'We do not track, share, or sell your data. Everything stays on your device.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Gold CTA
                    foregroundColor: Colors.black,
                  ),
                  onPressed: onNext,
                  child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

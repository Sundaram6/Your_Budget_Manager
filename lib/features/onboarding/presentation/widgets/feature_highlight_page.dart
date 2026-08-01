import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeatureHighlightPage extends StatelessWidget {
  final VoidCallback onNext;
  
  const FeatureHighlightPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Features designed for you',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: -0.2),
              const SizedBox(height: 48),
              _buildFeatureCard(
                context,
                icon: Icons.track_changes,
                title: 'Track',
                description: 'Easily track all your income and expenses in one place.',
                delay: 200,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.pie_chart,
                title: 'Budget',
                description: 'Set smart budgets and reach your financial goals faster.',
                delay: 400,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.security,
                title: 'Privacy',
                description: 'Offline-first. Your data is encrypted and secure.',
                delay: 600,
              ),
              const Spacer(),
              SizedBox(
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

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required String description, required int delay}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1);
  }
}

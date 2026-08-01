import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../engines/category/category_engine_provider.dart';

class CategorySetupPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  
  const CategorySetupPage({super.key, required this.onNext});

  @override
  ConsumerState<CategorySetupPage> createState() => _CategorySetupPageState();
}

class _CategorySetupPageState extends ConsumerState<CategorySetupPage> {
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _seedCategories();
  }

  Future<void> _seedCategories() async {
    final engine = ref.read(categoryEngineProvider);
    await engine.seedDefaults();
    if (mounted) {
      setState(() {
        _seeded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_seeded) {
      return const Center(child: CircularProgressIndicator());
    }

    final engine = ref.watch(categoryEngineProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Select Categories',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: -0.2),
              const SizedBox(height: 8),
              Text(
                'These are your default categories. You can edit them later.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder(
                  stream: engine.watchAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final categories = snapshot.data ?? [];
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Color(category.color)),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              Icon(
                                const IconData(
                                  0xe3a1,
                                  fontFamily: 'MaterialIcons',
                                ),
                                color: Color(category.color),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Checkbox(
                                value: true,
                                onChanged: (val) {},
                                activeColor: Color(category.color),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (300 + index * 100).ms);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Custom categories coming in Phase 2')),
                  );
                },
                child: const Text('Add Custom Category'),
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Gold CTA
                    foregroundColor: Colors.black,
                  ),
                  onPressed: widget.onNext,
                  child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ).animate().fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}

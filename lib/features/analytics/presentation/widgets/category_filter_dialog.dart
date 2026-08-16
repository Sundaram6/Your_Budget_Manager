import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../engines/analytics/providers/analytics_customization_provider.dart';
import '../../../categories/domain/entities/category.dart';

class CategoryFilterDialog extends ConsumerWidget {
  const CategoryFilterDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CategoryFilterDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hiddenCategories = ref.watch(analyticsHiddenCategoriesProvider);
    final notifier = ref.read(analyticsHiddenCategoriesProvider.notifier);

    final catRepo = ref.watch(categoryRepositoryProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.darkBorderGlass : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
              // Top drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customize Categories',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Exclude categories from chart & percentages',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_rounded),
                      tooltip: 'Done',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Action buttons (Show All / Hide All)
              FutureBuilder<List<Category>>(
                future: catRepo.getCategories(),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? [];
                  final expenseCategories = categories
                      .where((c) => c.id != 'cat_income')
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Row(
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.visibility_rounded, size: 16),
                          label: const Text('Show All'),
                          onPressed: () => notifier.reset(),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(Icons.visibility_off_rounded, size: 16),
                          label: const Text('Hide All'),
                          onPressed: () {
                            notifier.setHiddenCategories(
                              expenseCategories.map((c) => c.id).toSet(),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Category List
              Expanded(
                child: FutureBuilder<List<Category>>(
                  future: catRepo.getCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final categories = snapshot.data ?? [];
                    final expenseCategories = categories
                        .where((c) => c.id != 'cat_income')
                        .toList();

                    if (expenseCategories.isEmpty) {
                      return const Center(child: Text('No categories found.'));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: expenseCategories.length,
                      itemBuilder: (context, index) {
                        final cat = expenseCategories[index];
                        final isVisible = !hiddenCategories.contains(cat.id);

                        return CheckboxListTile(
                          value: isVisible,
                          activeColor: isDark ? AppColors.darkGoldPrimary : theme.colorScheme.primary,
                          secondary: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(cat.color).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.circle,
                              size: 14,
                              color: Color(cat.color),
                            ),
                          ),
                          title: Text(
                            cat.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isVisible
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                          subtitle: Text(
                            isVisible ? 'Visible in chart' : 'Hidden from chart',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          onChanged: (_) {
                            notifier.toggleCategory(cat.id);
                          },
                        );
                      },
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
}

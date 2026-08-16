import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_animation.dart';
import '../../../../engines/category/category_engine_provider.dart';
import '../../domain/entities/category.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final color = Color(cat.color);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: const Icon(Icons.category, color: Colors.white),
                ),
                title: Text(cat.name),
                subtitle: Text(cat.isDefault ? 'Default Category' : 'Custom Category'),
                trailing: cat.isDefault
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await ref.read(categoryEngineProvider).delete(cat);
                        },
                      ),
              ).animateEntrance(context, index: index);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddCategoryDialog(context, ref);
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                final engine = ref.read(categoryEngineProvider);
                final now = DateTime.now();
                await engine.add(
                  Category(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    icon: 'custom',
                    color: 0xFFFFC107,
                    isDefault: false,
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

final categoriesStreamProvider = StreamProvider((ref) {
  final engine = ref.watch(categoryEngineProvider);
  return engine.watchAll();
});

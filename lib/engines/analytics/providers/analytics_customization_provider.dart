import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kAnalyticsHiddenCategoriesKey = 'analytics_hidden_category_ids';

/// Manages the set of categories hidden by the user across Analytics and Insights charts.
/// Persists hidden category IDs into SharedPreferences.
class AnalyticsHiddenCategoriesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _loadFromPrefs();
    return <String>{};
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(kAnalyticsHiddenCategoriesKey);
      if (list != null) {
        state = list.toSet();
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs(Set<String> newSet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(kAnalyticsHiddenCategoriesKey, newSet.toList());
    } catch (_) {}
  }

  Future<void> toggleCategory(String categoryId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(categoryId)) {
      updated.remove(categoryId);
    } else {
      updated.add(categoryId);
    }
    state = updated;
    await _saveToPrefs(updated);
  }

  Future<void> hideCategory(String categoryId) async {
    if (!state.contains(categoryId)) {
      final updated = Set<String>.from(state)..add(categoryId);
      state = updated;
      await _saveToPrefs(updated);
    }
  }

  Future<void> showCategory(String categoryId) async {
    if (state.contains(categoryId)) {
      final updated = Set<String>.from(state)..remove(categoryId);
      state = updated;
      await _saveToPrefs(updated);
    }
  }

  Future<void> reset() async {
    state = <String>{};
    await _saveToPrefs(<String>{});
  }

  Future<void> setHiddenCategories(Set<String> categoryIds) async {
    state = Set<String>.from(categoryIds);
    await _saveToPrefs(state);
  }

  bool isHidden(String categoryId) => state.contains(categoryId);
}

final analyticsHiddenCategoriesProvider =
    NotifierProvider<AnalyticsHiddenCategoriesNotifier, Set<String>>(
  AnalyticsHiddenCategoriesNotifier.new,
);

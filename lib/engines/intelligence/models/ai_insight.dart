enum InsightType { warning, tip, achievement, suggestion }

class AiInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final DateTime generatedAt;
  final int priority; // 0 = highest priority, show first

  const AiInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.generatedAt,
    required this.priority,
  });
}

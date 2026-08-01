enum InsightType { positive, warning, info }

class Insight {
  const Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.actionLabel,
    this.actionRoute,
  });

  final String id;
  final String title;
  final String description;
  final InsightType type;
  final String? actionLabel;
  final String? actionRoute;
}

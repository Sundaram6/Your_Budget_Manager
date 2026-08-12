import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal.freezed.dart';
part 'savings_goal.g.dart';

enum SavingsGoalStatus { active, completed, paused }

@freezed
abstract class SavingsGoalModel with _$SavingsGoalModel {
  const factory SavingsGoalModel({
    required String id,
    required String name,
    required double targetAmount,
    required double currentAmount,
    String? categoryId,
    DateTime? targetDate,
    required DateTime startDate,
    required SavingsGoalStatus status,
    required String iconName,
    required String colorHex,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SavingsGoalModel;

  const SavingsGoalModel._();

  /// Progress from 0.0 to 1.0 (capped at 1.0).
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Remaining amount to reach the goal.
  double get remaining => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  /// Whether the goal has been fully funded.
  bool get isCompleted => status == SavingsGoalStatus.completed;

  /// Days remaining to target date. Returns null if no deadline.
  int? get daysRemaining => targetDate != null
      ? targetDate!.difference(DateTime.now()).inDays
      : null;

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalModelFromJson(json);
}

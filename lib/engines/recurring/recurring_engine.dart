import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../database/database_helper.dart';
import '../../models/recurring_transaction.dart';
import '../../models/transaction.dart';

class RecurringEngine {
  const RecurringEngine();

  static const _uuid = Uuid();
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// Instance method wrapper for Riverpod / DI callers.
  Future<int> processDueTransactions({DateTime? referenceDate}) {
    return processDueRecurring(referenceDate: referenceDate);
  }

  /// Instance method wrapper to watch all recurring transactions.
  Stream<List<RecurringTransactionModel>> watchAll() {
    return DatabaseHelper.instance.watchAllRecurringTransactions();
  }

  /// Instance method wrapper to insert a recurring transaction.
  Future<int> addRecurring(RecurringTransactionModel model) {
    return DatabaseHelper.instance.insertRecurringTransaction(model);
  }

  /// Instance method wrapper to delete a recurring transaction.
  Future<int> deleteRecurring(String id) {
    return DatabaseHelper.instance.deleteRecurringTransaction(id);
  }

  /// Instance method wrapper to manually force-generate a transaction.
  Future<int> forceGenerateTransaction(String recurringId) {
    return forceGenerate(recurringId);
  }

  /// Canonical processDueRecurring() — call on app startup and background sync:
  /// - Query active recurring transactions with next_due_date <= referenceDate (or today)
  /// - For each, process catch-up generation for every missed due date
  /// - Returns total count of generated transactions
  static Future<int> processDueRecurring({DateTime? referenceDate}) async {
    final now = referenceDate ?? DateTime.now();
    final todayStr = _dateFormat.format(now);

    final dueTransactions =
        await DatabaseHelper.instance.getDueRecurringTransactions(todayStr);

    int totalGeneratedCount = 0;
    for (final rt in dueTransactions) {
      final generated = await _processSingle(rt, now);
      totalGeneratedCount += generated;
    }

    return totalGeneratedCount;
  }

  /// Processes single recurring schedule catch-up generation.
  /// Loops while currentDue <= referenceDate (and <= endDate if specified).
  static Future<int> _processSingle(
    RecurringTransactionModel rt,
    DateTime referenceDate,
  ) async {
    final referenceDateStr = _dateFormat.format(referenceDate);
    DateTime currentDue = rt.nextDueDate;
    String currentDueStr = _dateFormat.format(currentDue);
    int generatedCount = 0;

    while (currentDueStr.compareTo(referenceDateStr) <= 0) {
      if (rt.endDate != null && currentDue.isAfter(rt.endDate!)) {
        break;
      }

      final notesText = rt.notes != null && rt.notes!.isNotEmpty
          ? '${rt.notes}\n[Auto-generated from recurring]'
          : '[Auto-generated from recurring]';

      final tx = TransactionModel(
        id: 'tx_${_uuid.v4()}',
        title: rt.title,
        amountPaise: rt.amountPaise,
        categoryId: rt.categoryId,
        type: rt.type,
        date: currentDue,
        notes: notesText,
        isRecurring: true,
        recurringId: rt.id,
        isAutoCaptured: false,
        sourceApp: null,
        createdAt: DateTime.now(),
      );

      await DatabaseHelper.instance.insertTransaction(tx);

      final nextDue = _calculateNextDue(currentDue, rt);
      final nextDueStr = _dateFormat.format(nextDue);
      final lastGenStr = _dateFormat.format(currentDue);
      final updatedAtStr = DateTime.now().toIso8601String();

      await DatabaseHelper.instance.updateRecurringTransactionDates(
        id: rt.id,
        nextDueDate: nextDueStr,
        lastGeneratedDate: lastGenStr,
        updatedAt: updatedAtStr,
      );

      generatedCount++;
      currentDue = nextDue;
      currentDueStr = nextDueStr;
    }

    return generatedCount;
  }

  /// Calculates next due date based on frequency and interval:
  /// - daily: +1 day
  /// - weekly: +7 days
  /// - biweekly: +14 days
  /// - monthly: safe month addition with day clamping (e.g. Jan 31 -> Feb 28)
  /// - yearly: safe year addition with leap-year day clamping (e.g. Feb 29 2024 -> Feb 28 2025)
  /// - custom: +intervalDays
  static DateTime _calculateNextDue(
      DateTime from, RecurringTransactionModel rt) {
    final freq = rt.frequency.toLowerCase();
    switch (freq) {
      case 'daily':
        return from.add(const Duration(days: 1));
      case 'weekly':
        return from.add(const Duration(days: 7));
      case 'biweekly':
        return from.add(const Duration(days: 14));
      case 'monthly':
        return _addMonths(from, 1);
      case 'yearly':
        return _addYears(from, 1);
      case 'custom':
        final interval = rt.intervalDays ?? 1;
        return from.add(Duration(days: interval));
      default:
        return from.add(const Duration(days: 1));
    }
  }

  /// Safely adds [months] to [from], clamping to the last valid day of the target month.
  static DateTime _addMonths(DateTime from, int months) {
    final targetYear = from.year + ((from.month + months - 1) ~/ 12);
    final targetMonth = ((from.month + months - 1) % 12) + 1;
    final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    final targetDay =
        from.day > daysInTargetMonth ? daysInTargetMonth : from.day;
    return DateTime(
        targetYear, targetMonth, targetDay, from.hour, from.minute, from.second);
  }

  /// Safely adds [years] to [from], handling leap year clamping.
  static DateTime _addYears(DateTime from, int years) {
    final targetYear = from.year + years;
    final daysInTargetMonth = DateTime(targetYear, from.month + 1, 0).day;
    final targetDay =
        from.day > daysInTargetMonth ? daysInTargetMonth : from.day;
    return DateTime(
        targetYear, from.month, targetDay, from.hour, from.minute, from.second);
  }

  /// Manually force generates a transaction for the specified recurring schedule.
  static Future<int> forceGenerate(String recurringId) async {
    final rt =
        await DatabaseHelper.instance.getRecurringTransactionById(recurringId);
    if (rt == null) return 0;

    final now = DateTime.now();
    final todayStr = _dateFormat.format(now);
    final nextDueStr = _dateFormat.format(rt.nextDueDate);

    if (nextDueStr.compareTo(todayStr) <= 0) {
      return _processSingle(rt, now);
    } else {
      final targetDate = rt.nextDueDate;
      final notesText = rt.notes != null && rt.notes!.isNotEmpty
          ? '${rt.notes}\n[Auto-generated from recurring]'
          : '[Auto-generated from recurring]';

      final tx = TransactionModel(
        id: 'tx_${_uuid.v4()}',
        title: rt.title,
        amountPaise: rt.amountPaise,
        categoryId: rt.categoryId,
        type: rt.type,
        date: targetDate,
        notes: notesText,
        isRecurring: true,
        recurringId: rt.id,
        isAutoCaptured: false,
        sourceApp: null,
        createdAt: DateTime.now(),
      );

      await DatabaseHelper.instance.insertTransaction(tx);

      final nextDue = _calculateNextDue(targetDate, rt);
      final newNextDueStr = _dateFormat.format(nextDue);
      final lastGenStr = _dateFormat.format(targetDate);
      final updatedAtStr = DateTime.now().toIso8601String();

      await DatabaseHelper.instance.updateRecurringTransactionDates(
        id: rt.id,
        nextDueDate: newNextDueStr,
        lastGeneratedDate: lastGenStr,
        updatedAt: updatedAtStr,
      );

      return 1;
    }
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/recurring_transaction.dart';

class RecurringTile extends StatelessWidget {
  final RecurringTransaction transaction;
  const RecurringTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Amount: \${transaction.amount.value}'),
      subtitle: Text('Frequency: \${transaction.frequency.name}'),
    );
  }
}

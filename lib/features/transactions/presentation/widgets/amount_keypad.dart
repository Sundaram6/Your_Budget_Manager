import 'package:flutter/material.dart';

class AmountKeypad extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const AmountKeypad({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onSubmit,
  });

  void _onKeyPress(String key) {
    if (key == 'delete') {
      if (value.isNotEmpty) {
        onChanged(value.substring(0, value.length - 1));
      }
    } else if (key == 'done') {
      onSubmit();
    } else if (key == '.') {
      if (!value.contains('.')) {
        onChanged(value.isEmpty ? '0.' : '$value.');
      }
    } else {
      // Limit to 2 decimal places
      if (value.contains('.')) {
        final parts = value.split('.');
        if (parts.length > 1 && parts[1].length >= 2) return;
      }
      // Limit total length to avoid overflow
      if (value.length >= 10) return;

      onChanged(value == '0' ? key : '$value$key');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          _buildRow(['4', '5', '6']),
          _buildRow(['7', '8', '9']),
          _buildRow(['.', '0', 'delete']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: InkWell(
            onTap: () => _onKeyPress(key),
            child: Container(
              height: 60,
              alignment: Alignment.center,
              child: _buildKeyContent(key),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyContent(String key) {
    if (key == 'delete') {
      return const Icon(Icons.backspace_outlined);
    } else if (key == 'done') {
      return const Icon(Icons.check, color: Colors.green);
    }
    return Text(
      key,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
    );
  }
}

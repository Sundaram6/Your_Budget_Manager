import 'package:flutter/material.dart';

import '../../theme/app_custom_tokens.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final String submitLabel;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onSubmit,
    this.submitLabel = 'Add',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey(context, '.', isAction: false),
            _buildKey(context, '0'),
            _buildBackspaceKey(context),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).extension<AppCustomTokens>()!.heroSurfaceColor,
              foregroundColor: Theme.of(context).extension<AppCustomTokens>()!.heroTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              submitLabel,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).extension<AppCustomTokens>()!.heroTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKey(context, key)).toList(),
    );
  }

  Widget _buildKey(BuildContext context, String key, {bool isAction = false}) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 2,
        child: InkWell(
          onTap: () => onKeyPressed(key),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              key,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 2,
        child: InkWell(
          onTap: onBackspace,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RightWidget extends StatelessWidget {
  const RightWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        child: const Center(child: Text('Right Widget')),
      ),
    );
  }
}

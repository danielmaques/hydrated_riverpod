import 'package:flutter/material.dart';

/// Info card explaining what the example app demonstrates
class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'About this example',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This app demonstrates hydrated_riverpod. All state is automatically '
              'persisted and will be restored when you restart the app.\n\n'
              '• Counter value persists\n'
              '• Theme preference persists\n'
              '• Todo list persists with debounce',
            ),
          ],
        ),
      ),
    );
  }
}

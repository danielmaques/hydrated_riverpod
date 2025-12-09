import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import '../widgets/counter_section.dart';
import '../widgets/info_card.dart';
import '../widgets/todo_section.dart';

/// Home page displaying all example sections
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydrated Riverpod'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          InfoCard(),
          SizedBox(height: 16),
          CounterSection(),
          SizedBox(height: 16),
          TodoSection(),
        ],
      ),
    );
  }
}

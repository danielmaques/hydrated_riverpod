import 'dart:io';

import 'package:hydrated_riverpod/hydrated_riverpod.dart';
import 'package:riverpod/riverpod.dart';

Future<void> main() async {
  final tempDir = await Directory.systemTemp.createTemp('hydrated_example_');
  final storage = await HiveHydratedStorage.build(
    storageDirectory: tempDir.path,
  );

  HydratedStorage.instance = storage;

  final container = ProviderContainer();
  final notifier = container.read(counterProvider.notifier);

  stdout.writeln('Initial value: ${container.read(counterProvider)}');
  notifier.increment();
  notifier.increment();

  stdout.writeln('After increments: ${container.read(counterProvider)}');

  // Dispose + reopen to prove persistence
  container.dispose();

  final secondContainer = ProviderContainer();
  stdout.writeln('Restored value: ${secondContainer.read(counterProvider)}');

  secondContainer.dispose();
  await storage.clear();
  await storage.close();
  await tempDir.delete(recursive: true);
}

class CounterNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;
  void reset() => state = 0;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

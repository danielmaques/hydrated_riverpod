import 'package:hydrated_riverpod/hydrated_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple counter that persists between app restarts
class CounterNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

import 'dart:io';

import 'package:hydrated_riverpod/hydrated_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

class TestCounterNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;
  void decrement() => state--;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

class TestTodoNotifier extends HydratedNotifier<List<String>> {
  @override
  List<String> build() => hydrate() ?? [];

  void addTodo(String todo) => state = [...state, todo];
  void removeTodo(int index) => state = [
        ...state.sublist(0, index),
        ...state.sublist(index + 1),
      ];

  @override
  Map<String, dynamic>? toJson(List<String> state) => {'todos': state};

  @override
  List<String>? fromJson(Map<String, dynamic> json) =>
      (json['todos'] as List<dynamic>?)?.cast<String>();
}

void main() {
  late Directory tempDir;
  late HiveHydratedStorage storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hydrated_test_');
    storage = await HiveHydratedStorage.build(
      storageDirectory: tempDir.path,
      boxName: 'test_box',
    );
    HydratedStorage.instance = storage;
  });

  tearDown(() async {
    await storage.clear();
    await storage.close();
    await tempDir.delete(recursive: true);
  });

  group('HydratedNotifier', () {
    test('should start with initial state', () {
      final counterProvider = NotifierProvider<TestCounterNotifier, int>(
        TestCounterNotifier.new,
      );

      final container = ProviderContainer();
      expect(container.read(counterProvider), equals(0));
      container.dispose();
    });

    test('should persist and restore state', () async {
      final counterProvider = NotifierProvider<TestCounterNotifier, int>(
        TestCounterNotifier.new,
      );

      // Primeiro container
      final container1 = ProviderContainer();
      container1.read(counterProvider.notifier).increment();
      container1.read(counterProvider.notifier).increment();
      expect(container1.read(counterProvider), equals(2));

      // Aguarda um pouco para garantir que o estado seja salvo
      await Future.delayed(Duration(milliseconds: 100));

      // Dispose para salvar
      container1.dispose();

      // Segundo container - deve restaurar estado
      final container2 = ProviderContainer();
      expect(container2.read(counterProvider), equals(2));
      container2.dispose();
    });

    test('should handle complex state', () async {
      final todoProvider = NotifierProvider<TestTodoNotifier, List<String>>(
        TestTodoNotifier.new,
      );

      final container1 = ProviderContainer();
      container1.read(todoProvider.notifier).addTodo('Test 1');
      container1.read(todoProvider.notifier).addTodo('Test 2');
      expect(container1.read(todoProvider), equals(['Test 1', 'Test 2']));

      container1.dispose();

      final container2 = ProviderContainer();
      expect(container2.read(todoProvider), equals(['Test 1', 'Test 2']));
      container2.dispose();
    });

    test('should handle clear method', () async {
      final counterProvider = NotifierProvider<TestCounterNotifier, int>(
        TestCounterNotifier.new,
      );

      final container1 = ProviderContainer();
      container1.read(counterProvider.notifier).increment();
      expect(container1.read(counterProvider), equals(1));

      await container1.read(counterProvider.notifier).clear();
      container1.dispose();

      final container2 = ProviderContainer();
      expect(container2.read(counterProvider),
          equals(0)); // Deve voltar ao estado inicial
      container2.dispose();
    });

    test('should handle serialization errors gracefully', () {
      final failingProvider = NotifierProvider<FailingNotifier, int>(
        FailingNotifier.new,
      );

      final container = ProviderContainer();

      // Notifier que sempre falha na serialização
      container.read(failingProvider.notifier).increment();
      expect(container.read(failingProvider),
          equals(1)); // Deve funcionar mesmo com erro

      container.dispose();
    });

    test('should ignore non-map serialization output', () {
      final provider = NotifierProvider<NonMapNotifier, int>(
        NonMapNotifier.new,
      );

      final container1 = ProviderContainer();
      container1.read(provider.notifier).increment();
      expect(container1.read(provider), 1);
      container1.dispose();

      // Como toJson retorna null, não deve persistir o valor anterior
      final container2 = ProviderContainer();
      expect(container2.read(provider), 0);
      container2.dispose();
    });

    test('should isolate storageKey by suffix', () async {
      final memory = InMemoryHydratedStorage();
      HydratedStorage.instance = memory;

      final first = NotifierProvider<SuffixNotifier, int>(
        () => SuffixNotifier('a'),
      );
      final second = NotifierProvider<SuffixNotifier, int>(
        () => SuffixNotifier('b'),
      );

      final container = ProviderContainer();
      container.read(first.notifier).bump();
      container.read(second.notifier).bump();
      container.read(second.notifier).bump();

      await Future<void>.delayed(const Duration(milliseconds: 70));
      container.dispose();

      expect(memory.store['SuffixNotifier:a'], equals({'value': 1}));
      expect(memory.store['SuffixNotifier:b'], equals({'value': 2}));
    });

    test('should debounce rapid writes', () async {
      final memory = InMemoryHydratedStorage();
      HydratedStorage.instance = memory;

      final provider = NotifierProvider<DebouncedNotifier, int>(
        DebouncedNotifier.new,
      );

      final container = ProviderContainer();
      final notifier = container.read(provider.notifier);

      notifier.bump();
      notifier.bump();
      notifier.bump();

      // Dentro da janela de debounce
      await Future<void>.delayed(const Duration(milliseconds: 20));
      notifier.bump();

      await Future<void>.delayed(const Duration(milliseconds: 120));
      container.dispose();

      expect(memory.writeCount, 1);
      expect(memory.store['DebouncedNotifier'], {'value': 4});
    });

    test('should flush pending debounced write on dispose', () async {
      final memory = InMemoryHydratedStorage();
      HydratedStorage.instance = memory;

      final provider = NotifierProvider<DebouncedAutoDisposeNotifier, int>(
        DebouncedAutoDisposeNotifier.new,
      );

      final container = ProviderContainer();
      container.read(provider.notifier).bump();
      // Dispose antes do debounce disparar, deve forçar flush
      container.dispose();

      expect(memory.writeCount, 1);
      expect(memory.store['DebouncedAutoDisposeNotifier'], {'value': 1});
    });
  });
}

class FailingNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  @override
  Map<String, dynamic>? toJson(int state) =>
      throw Exception('Serialization failed');

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

class NonMapNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  @override
  Map<String, dynamic>? toJson(int state) => null; // nunca persiste

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

class SuffixNotifier extends HydratedNotifier<int> {
  SuffixNotifier(this.id);

  final String id;

  @override
  String? get storageKeySuffix => id;

  @override
  int build() => hydrate() ?? 0;

  void bump() => state++;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

class DebouncedNotifier extends HydratedNotifier<int> {
  @override
  Duration get writeDebounce => const Duration(milliseconds: 50);

  @override
  int build() => hydrate() ?? 0;

  void bump() => state++;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

class DebouncedAutoDisposeNotifier extends AutoDisposeHydratedNotifier<int> {
  @override
  Duration get writeDebounce => const Duration(milliseconds: 50);

  @override
  int build() => hydrate() ?? 0;

  void bump() => state++;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

class InMemoryHydratedStorage implements HydratedStorage {
  final Map<String, dynamic> store = {};
  int writeCount = 0;

  @override
  Future<void> clear() async {
    store.clear();
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> delete(String key) async {
    store.remove(key);
  }

  @override
  read(String key) => store[key];

  @override
  Future<void> write(String key, value) async {
    writeCount++;
    store[key] = value;
  }
}

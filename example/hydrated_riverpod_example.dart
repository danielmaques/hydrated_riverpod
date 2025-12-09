import 'dart:io';

import 'package:hydrated_riverpod/hydrated_riverpod.dart';
import 'package:riverpod/riverpod.dart';

/// Exemplo simples de contador que persiste seu estado
class CounterNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;
  void decrement() => state--;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

/// Exemplo de lista de tarefas que persiste seu estado
class TodoNotifier extends HydratedNotifier<List<String>> {
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

/// Exemplo auto-dispose com debounce e chave por instância
class SessionCounterNotifier extends AutoDisposeHydratedNotifier<int> {
  SessionCounterNotifier(this.sessionId);

  final String sessionId;

  @override
  String? get storageKeySuffix => sessionId;

  @override
  Duration get writeDebounce => const Duration(milliseconds: 100);

  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

void main() async {
  // Inicializar armazenamento
  final storage = await HiveHydratedStorage.build(
    storageDirectory: Directory.current.path,
    boxName: 'example_box',
  );

  HydratedStorage.instance = storage;

  // Criar container do Riverpod
  final container = ProviderContainer();

  // Exemplo com contador
  print('=== Exemplo Counter ===');
  final counterProvider = NotifierProvider<CounterNotifier, int>(
    CounterNotifier.new,
  );

  print('Estado inicial: ${container.read(counterProvider)}');
  container.read(counterProvider.notifier).increment();
  container.read(counterProvider.notifier).increment();
  print('Após incrementos: ${container.read(counterProvider)}');

  // Dispose para salvar
  container.dispose();

  // Criar novo container para testar persistência
  final newContainer = ProviderContainer();
  print('Estado restaurado: ${newContainer.read(counterProvider)}');

  // Exemplo com lista de tarefas
  print('\n=== Exemplo Todo List ===');
  final todoProvider = NotifierProvider<TodoNotifier, List<String>>(
    TodoNotifier.new,
  );

  print('Tarefas iniciais: ${newContainer.read(todoProvider)}');
  newContainer.read(todoProvider.notifier).addTodo('Aprender Dart');
  newContainer.read(todoProvider.notifier).addTodo('Criar app Flutter');
  newContainer.read(todoProvider.notifier).addTodo('Publicar no pub.dev');
  print('Após adicionar tarefas: ${newContainer.read(todoProvider)}');

  newContainer.read(todoProvider.notifier).removeTodo(1);
  print('Após remover tarefa: ${newContainer.read(todoProvider)}');

  // Exemplo com AutoDispose + chave customizada
  print('\n=== Exemplo AutoDispose com debounce ===');
  final sessionProvider =
      NotifierProvider<SessionCounterNotifier, int>(() => SessionCounterNotifier('sessao-demo'));

  print('Sessão estado inicial: ${newContainer.read(sessionProvider)}');
  newContainer.read(sessionProvider.notifier).increment();
  newContainer.read(sessionProvider.notifier).increment();
  await Future<void>.delayed(const Duration(milliseconds: 150));
  print('Sessão após incrementos: ${newContainer.read(sessionProvider)}');

  newContainer.dispose();

  // Limpar armazenamento de exemplo
  await storage.clear();
  await storage.close();

  print('\nExemplo concluído!');
}

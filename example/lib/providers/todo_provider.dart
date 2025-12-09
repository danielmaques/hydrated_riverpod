import 'package:hydrated_riverpod/hydrated_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo.dart';

/// Todo list notifier - demonstrates complex state with debounce
class TodoNotifier extends HydratedNotifier<List<Todo>> {
  @override
  Duration get writeDebounce => const Duration(milliseconds: 300);

  @override
  List<Todo> build() => hydrate() ?? [];

  void add(String title) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    state = [...state, Todo(id: id, title: title)];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(completed: !todo.completed) else todo,
    ];
  }

  void remove(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void clearCompleted() {
    state = state.where((todo) => !todo.completed).toList();
  }

  @override
  Map<String, dynamic>? toJson(List<Todo> state) => {
        'todos': state.map((t) => t.toJson()).toList(),
      };

  @override
  List<Todo>? fromJson(Map<String, dynamic> json) {
    final todos = json['todos'] as List?;
    if (todos == null) return null;
    return todos
        .map((t) => Todo.fromJson(Map<String, dynamic>.from(t as Map)))
        .toList();
  }
}

final todoProvider = NotifierProvider<TodoNotifier, List<Todo>>(
  TodoNotifier.new,
);

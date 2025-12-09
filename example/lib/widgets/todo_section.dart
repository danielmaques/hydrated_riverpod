import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';

/// Todo section widget demonstrating complex persistent state with debounce
class TodoSection extends ConsumerStatefulWidget {
  const TodoSection({super.key});

  @override
  ConsumerState<TodoSection> createState() => _TodoSectionState();
}

class _TodoSectionState extends ConsumerState<TodoSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(todoProvider.notifier).add(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoProvider);
    final completedCount = todos.where((t) => t.completed).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checklist,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Persistent Todos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (todos.isNotEmpty)
                  Chip(
                    label: Text('$completedCount/${todos.length}'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a new todo...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addTodo,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (todos.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No todos yet',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              ...todos.map((todo) => _TodoTile(todo: todo)),
              if (completedCount > 0) ...[
                const Divider(),
                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        ref.read(todoProvider.notifier).clearCompleted(),
                    icon: const Icon(Icons.delete_sweep),
                    label: Text('Clear $completedCount completed'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TodoTile extends ConsumerWidget {
  const _TodoTile({required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: todo.completed,
        onChanged: (_) => ref.read(todoProvider.notifier).toggle(todo.id),
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.completed ? TextDecoration.lineThrough : null,
          color: todo.completed ? Theme.of(context).colorScheme.outline : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 20),
        onPressed: () => ref.read(todoProvider.notifier).remove(todo.id),
        tooltip: 'Remove',
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/todo_store.dart';
import 'package:provider/provider.dart';
import 'build_task_card.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todoStore = context.watch<TodoStore>();
    final todos = todoStore.filteredTasks;
    final brightness = Theme.of(context).brightness;

    return ListView.builder(
      key: ValueKey('todo-list-${brightness.name}'),
      padding: const EdgeInsets.all(12),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final task = todos[index];
        return Dismissible(
          key: ValueKey(
            '${task.taskId ?? '${task.title}-$index'}-${brightness.name}',
          ),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: buildTaskCard(context, task, index),
          onDismissed: (_) async {
            await todoStore.removeTask(task);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task deleted successfully'),
                backgroundColor: Colors.red,
              ),
            );
          },
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text(
                        'Are you sure you want to delete this task?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                ) ??
                false;
          },
        );
      },
    );
  }
}

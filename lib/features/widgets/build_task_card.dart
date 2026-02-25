import 'package:intl/intl.dart';
import '../presentation/edit_task_screen.dart';
import '../models/todo_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final DateFormat _taskDateFormat = DateFormat('yyyy-MMM-dd');

Widget buildTaskCard(BuildContext context, TaskTodo todo, int index) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final priorityColor = _getPriorityColor(todo.taskPriority.name);
  final animationDelay = (index * 40).clamp(0, 400);
  final cardColor = theme.cardTheme.color ?? colorScheme.surfaceContainer;
  final borderColor = colorScheme.outlineVariant;
  final titleColor = theme.textTheme.bodyLarge?.color ?? colorScheme.onSurface;
  final secondaryTextColor =
      theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
      colorScheme.onSurface.withValues(alpha: 0.7);
  final dateColor =
      theme.textTheme.bodySmall?.color ?? colorScheme.onSurfaceVariant;
  final shadowOpacity = theme.brightness == Brightness.dark ? 0.24 : 0.06;

  return TweenAnimationBuilder(
    duration: Duration(milliseconds: 250 + animationDelay),
    tween: Tween<double>(begin: 0, end: 1),
    builder: (context, double value, child) {
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTaskScreen(todo: todo),
              ),
            );
          },
          // detail
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(todo.title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Description: ${todo.description ?? ''}"),
                    Text("Deadline: ${_taskDateFormat.format(todo.dateTime)}"),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () {
                    context.read<TodoStore>().updateTask(
                      todo.copyWith(isCompleted: !todo.isCompleted),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: todo.isCompleted
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                      border: Border.all(
                        color: todo.isCompleted
                            ? const Color(0xFF10B981)
                            : borderColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: todo.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // Task Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Title
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: todo.isCompleted
                              ? theme.disabledColor
                              : titleColor,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description and time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (todo.description != null &&
                              todo.description!.isNotEmpty)
                            Text(
                              todo.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            _taskDateFormat.format(todo.dateTime),
                            style: TextStyle(
                              fontSize: 13,
                              color: dateColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Priority Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    todo.taskPriority.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Color _getPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return const Color(0xFFEF4444).withAlpha(200);
    case 'medium':
      return const Color(0xFFF59E0B).withAlpha(200);
    case 'low':
      return const Color(0xFF10B981).withAlpha(200);
    default:
      return Colors.grey;
  }
}

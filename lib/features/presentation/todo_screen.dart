import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/live_clock.dart';
import '../models/todo_store.dart';
import '../providers/user_provider.dart';
import '../widgets/build_state_card.dart';
import '../widgets/empty_list.dart';
import '../widgets/todo_list.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  static final DateFormat _weekdayFormat = DateFormat('EEEE');
  static final DateFormat _dateFormat = DateFormat('MMMM d, y');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoStore>().loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final isDarkMode = userProvider.user?.isDarkMode ?? false;
    final todoStore = context.watch<TodoStore>();
    final stats = _calculateStats(todoStore);
    final headerBgColor = isDarkMode
        ? theme.cardColor
        : const Color.fromARGB(255, 54, 115, 219);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeaderSection(
              context,
              theme,
              isDarkMode,
              userProvider,
              headerBgColor,
              stats,
            ),
            Expanded(
              child: todoStore.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : todoStore.filteredTasks.isEmpty
                  ? EmptyList(key: ValueKey(isDarkMode))
                  : TodoList(key: ValueKey(isDarkMode)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        label: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(context, '/add_task');
        },
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
    UserProvider userProvider,
    Color backgroundColor,
    Map<String, int> stats,
  ) {
    const onHeaderColor = Colors.white;
    const onHeaderColorSecondary = Colors.white70;
    final hasTasksCompleted = (stats['completed'] ?? 0) > 0;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weekdayFormat.format(DateTime.now()),
                    style: const TextStyle(
                      color: onHeaderColorSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _dateFormat.format(DateTime.now()),
                    style: const TextStyle(
                      color: onHeaderColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const LiveClock(
                    style: TextStyle(
                      color: onHeaderColorSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: onHeaderColor,
                    ),
                    onPressed: () async {
                      await userProvider.toggleTheme(!isDarkMode);
                      if (!mounted) return;
                      setState(() {});
                    },
                    tooltip: isDarkMode
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode',
                  ),
                  const SizedBox(width: 8),
                  _buildProfileAvatar(context, userProvider.user?.imageUrl),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Tasks',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: onHeaderColor,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      _buildGreetingMessage(),
                      style: const TextStyle(
                        color: onHeaderColorSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasTasksCompleted)
                TextButton(
                  onPressed: () async {
                    await context.read<TodoStore>().clearCompleted();
                  },
                  child: const Text(
                    'Clear Completed',
                    style: TextStyle(color: onHeaderColor, fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(context, onHeaderColor),
          const SizedBox(height: 16),
          _buildStatsRow(stats),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, String? imageUrl) {
    final imageProvider = _resolveImageProvider(imageUrl);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(30),
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
        ),
        child: imageProvider == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
    );
  }

  ImageProvider<Object>? _resolveImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }
    try {
      return MemoryImage(base64Decode(imageUrl));
    } catch (_) {
      return null;
    }
  }

  Widget _buildSearchBar(BuildContext context, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (value) => context.read<TodoStore>().searchTask(value),
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search tasks...',
          hintStyle: TextStyle(color: Colors.white.withAlpha(150)),
          prefixIcon: Icon(Icons.search, color: iconColor),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    return Row(
      children: [
        Expanded(
          child: buildStatCard(
            'Active',
            stats['active'].toString(),
            Icons.pending_actions,
            const Color(0xFFFFA726).withAlpha(20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildStatCard(
            'Done',
            stats['completed'].toString(),
            Icons.check_circle,
            const Color(0xFF66BB6A).withAlpha(20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildStatCard(
            'Total',
            stats['total'].toString(),
            Icons.list_alt,
            const Color(0xFF42A5F5).withAlpha(20),
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateStats(TodoStore store) {
    return {
      'total': store.tasks.length,
      'active': store.tasks.where((t) => !t.isCompleted).length,
      'completed': store.tasks.where((t) => t.isCompleted).length,
    };
  }

  String _buildGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Let's make today productive!";
    if (hour < 17) return 'Keep up the great work!';
    return 'Finish strong!';
  }
}

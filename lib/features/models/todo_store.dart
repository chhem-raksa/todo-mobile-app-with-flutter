import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'task_enums.dart';

class TaskTodo {
  final String? taskId;
  final String title;
  final String? description;
  final DateTime dateTime;
  final TaskPriority taskPriority;
  final bool isCompleted;

  TaskTodo({
    this.taskId,
    required this.title,
    this.description,
    required this.dateTime,
    required this.taskPriority,
    required this.isCompleted,
  });

  TaskTodo copyWith({
    String? taskId,
    String? title,
    String? description,
    DateTime? dateTime,
    TaskPriority? taskPriority,
    bool? isCompleted,
  }) {
    return TaskTodo(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      taskPriority: taskPriority ?? this.taskPriority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() { //convert to json
    return {
      'id': taskId,
      'title': title,
      'description': description ?? '',
      'dateTime': dateTime.toIso8601String(),
      'taskPriority': taskPriority.name,
      'isCompleted': isCompleted,
    };
  }

  factory TaskTodo.fromJson(Map<String, dynamic> json) { //convert from json
    return TaskTodo(
      taskId: json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'].toString())
          : DateTime.now(),
      taskPriority: _parsePriority(json['taskPriority']?.toString()),
      isCompleted: json['isCompleted'] == true,
    );
  }

  static TaskPriority _parsePriority(String? priority) { //convert priority to enum
    switch (priority) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}

class TodoStore extends ChangeNotifier { //manage todo state 
  static const _localTasksKey = 'local_tasks_cache';
  final ApiService _apiService = ApiService();
  final List<TaskTodo> _tasks = [];

  void _sortTasks() {
    int priorityScore(TaskPriority p) {
      switch (p) {
        case TaskPriority.high:
          return 2;
        case TaskPriority.medium:
          return 1;
        case TaskPriority.low:
          return 0;
      }
    }

    _tasks.sort((a, b) {
      final dateCmp = a.dateTime.compareTo(b.dateTime);
      if (dateCmp != 0) return dateCmp; // earlier deadlines first
      return priorityScore(b.taskPriority) - priorityScore(a.taskPriority);
      // for same deadline: high -> medium -> low
    });
  }

  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
// get todos
  List<TaskTodo> get tasks => _tasks;
// get search query
  String get searchQuery => _searchQuery;
// get is loading
  bool get isLoading => _isLoading;
// get error message
  String? get errorMessage => _errorMessage;
// get filtered todos
  List<TaskTodo> get filteredTasks {
    if (_searchQuery.isEmpty) return _tasks;
    final query = _searchQuery.toLowerCase();
    return _tasks
        .where((task) => task.title.toLowerCase().contains(query))
        .toList();
  }
  int get remainingTasks => _tasks.where((task) => !task.isCompleted).length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
// load todos from api and local storage
  Future<void> loadTodos() async { 
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // notify listeners that the state has changed

    try {
      final cachedLocal = await _loadTasksFromLocal();
      final pendingLocal = cachedLocal
          .where((task) => _isLocalTaskId(task.taskId))
          .toList();

      final todos = await _apiService.getTodos();
      final serverIds = todos
          .map((task) => task.taskId)
          .whereType<String>()
          .toSet();
      final mergedPending = pendingLocal
          .where((task) => !serverIds.contains(task.taskId))
          .toList();

      _tasks
        ..clear()
        ..addAll(todos);
      _tasks.addAll(mergedPending);
      _sortTasks();
      await _saveTasksToLocal();
    } catch (_) { // if failed to load todos from api, load from local storage
      final localTodos = await _loadTasksFromLocal();
      _tasks
        ..clear()
        ..addAll(localTodos);
      _sortTasks();
      _errorMessage = localTodos.isEmpty ? 'Failed to load todos' : null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
// add new todo to api and local storage
  Future<void> addTask(TaskTodo task) async {
    _errorMessage = null;
    try {
      final newTask = await _apiService.addTodo(task);
      _tasks.add(newTask);
    } catch (_) {
      final localTask = task.copyWith(
        taskId: task.taskId ?? _generateLocalTaskId(),
      );
      _tasks.add(localTask);
    }
    _sortTasks();
    await _saveTasksToLocal();
    notifyListeners();
  }
// remove todo from api and local storage
  Future<void> removeTask(TaskTodo task) async {
    _errorMessage = null;
    _tasks.remove(task);
    _sortTasks();
    await _saveTasksToLocal();
    notifyListeners();

    final id = task.taskId;
    if (_isLocalTaskId(id)) {
      return;
    }

    try {
      await _apiService.deleteTodo(id!);
    } catch (_) {
      _errorMessage = 'Task deleted locally. Server sync failed.';
      notifyListeners();
    }
  }
// update todo in api and local storage
  Future<void> updateTask(TaskTodo task) async {
    _errorMessage = null;
    final index = _tasks.indexWhere((t) => t.taskId == task.taskId);
    if (index == -1) return;

    _tasks[index] = task;
    _sortTasks();

    if (!_isLocalTaskId(task.taskId)) {
      try {
        await _apiService.updateTodo(task);
      } catch (_) {}
    }
    await _saveTasksToLocal();
    notifyListeners();
  }
// clear completed todos from api and local storage
  Future<void> clearCompleted() async {
    _errorMessage = null;
    final completed = _tasks.where((task) => task.isCompleted).toList();
    for (final task in completed) {
      final id = task.taskId;
      if (!_isLocalTaskId(id)) {
        try {
          await _apiService.deleteTodo(id!);
        } catch (_) {}
      }
    }
    _tasks.removeWhere((task) => task.isCompleted);
    _sortTasks();
    await _saveTasksToLocal();
    notifyListeners();
  }
// toggle todo completion in api and local storage
  void toggleTodo(String id) {
    final index = _tasks.indexWhere((todo) => todo.taskId == id);
    if (index == -1) return;
    updateTask(_tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted));
  }
// search todos
  void searchTask(String query) {
    _searchQuery = query;
    notifyListeners();
  }
// save todos to local storage
  Future<void> _saveTasksToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_localTasksKey, jsonEncode(tasksJson));
  }
// load todos from local storage
  Future<List<TaskTodo>> _loadTasksFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_localTasksKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final data = List<Map<String, dynamic>>.from(
        (jsonDecode(jsonString) as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
      return data.map(TaskTodo.fromJson).toList();
    } catch (_) {
      return [];
    }
  }
// check if task id is local
  bool _isLocalTaskId(String? id) {
    return id == null || id.isEmpty || id.startsWith('local-');
  }
// generate local task id
  String _generateLocalTaskId() {
    return 'local-${DateTime.now().millisecondsSinceEpoch}';
  }
}

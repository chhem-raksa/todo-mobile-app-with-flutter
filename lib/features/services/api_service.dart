import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/task_enums.dart';
import '../models/todo_store.dart';

class ApiService {
  final String apiUrl = 'http://localhost:3000';
  String get _baseUrl {
    if (kIsWeb) return apiUrl;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return apiUrl;
    }
    return apiUrl;
  }

  String get _usersUrl => '$_baseUrl/users';
  String get _todosUrl => '$_baseUrl/todos';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse(
      _usersUrl,
    ).replace(queryParameters: {'email': email, 'password': password});

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) throw Exception('Login failed');

      final List<dynamic> users = jsonDecode(response.body) as List<dynamic>;
      if (users.isEmpty) throw Exception('Invalid email or password');

      final user = Map<String, dynamic>.from(users.first as Map);
      return {'token': 'fake-jwt-token-${user['id']}', 'user': user};
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password, {
    String? name,
    String? imageUrl,
    String? title,
    String? about,
    String? phoneNumber,
  }) async {
    final checkUri = Uri.parse(
      _usersUrl,
    ).replace(queryParameters: {'email': email});

    try {
      final checkResponse = await http.get(checkUri);
      final List<dynamic> existingUsers =
          jsonDecode(checkResponse.body) as List<dynamic>;
      if (existingUsers.isNotEmpty) {
        throw Exception('Email already registered');
      }

      final response = await http.post(
        Uri.parse(_usersUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name ?? email.split('@').first,
          'imageUrl': imageUrl ?? '',
          'isDarkMode': false,
          'title': title ?? '',
          'about': about ?? '',
          'phoneNumber': phoneNumber ?? '',
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 201) throw Exception('Registration failed');
      final newUser = jsonDecode(response.body) as Map<String, dynamic>;
      return {'token': 'fake-jwt-token-${newUser['id']}', 'user': newUser};
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String id,
    required String email,
    required String password,
    required String name,
    required String imageUrl,
    required bool isDarkMode,
    String? title,
    String? about,
    String? phoneNumber,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_usersUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'email': email,
          'password': password,
          'name': name,
          'imageUrl': imageUrl,
          'isDarkMode': isDarkMode,
          'title': title ?? '',
          'about': about ?? '',
          'phoneNumber': phoneNumber ?? '',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<TaskTodo>> getTodos() async {
    try {
      final response = await http.get(Uri.parse(_todosUrl));
      if (response.statusCode != 200) throw Exception('Failed to load todos');

      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => _mapJsonToTask(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<TaskTodo> addTodo(TaskTodo task) async {
    try {
      final response = await http.post(
        Uri.parse(_todosUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': task.title,
          'description': task.description ?? '',
          'dateTime': task.dateTime.toIso8601String(),
          'taskPriority': task.taskPriority.name,
          'isCompleted': task.isCompleted,
        }),
      );

      if (response.statusCode != 201) throw Exception('Failed to add todo');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _mapJsonToTask(json);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateTodo(TaskTodo task) async {
    try {
      final response = await http.put(
        Uri.parse('$_todosUrl/${task.taskId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': task.taskId,
          'title': task.title,
          'description': task.description ?? '',
          'dateTime': task.dateTime.toIso8601String(),
          'taskPriority': task.taskPriority.name,
          'isCompleted': task.isCompleted,
        }),
      );

      if (response.statusCode != 200) throw Exception('Failed to update todo');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_todosUrl/$id'));
      if (response.statusCode != 200) throw Exception('Failed to delete todo');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  TaskTodo _mapJsonToTask(Map<String, dynamic> json) {
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

  TaskPriority _parsePriority(String? priority) {
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

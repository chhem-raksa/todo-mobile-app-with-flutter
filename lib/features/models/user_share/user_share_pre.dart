import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../user.dart';

class UserSharePre {
  static const String _userKey = 'user';
  static const String _registeredUsersKey = 'registered_users';

  // Save current logged-in user
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Get current logged-in user
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Remove current user (logout)
  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Register a new user
  Future<void> registerUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> usersJson =
        prefs.getStringList(_registeredUsersKey) ?? [];

    // Check if user already exists
    for (String u in usersJson) {
      final existingUser = User.fromJson(jsonDecode(u));
      if (existingUser.email == user.email) {
        throw Exception('User with this email already exists.');
      }
    }

    usersJson.add(jsonEncode(user.toJson()));
    await prefs.setStringList(_registeredUsersKey, usersJson);
  }

  // Update registered user after profile edit
  Future<void> updateRegisteredUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> usersJson =
        prefs.getStringList(_registeredUsersKey) ?? [];

    for (int i = 0; i < usersJson.length; i++) {
      final existingUser = User.fromJson(jsonDecode(usersJson[i]));
      if (existingUser.id == updatedUser.id ||
          existingUser.email == updatedUser.email) {
        usersJson[i] = jsonEncode(updatedUser.toJson());
        await prefs.setStringList(_registeredUsersKey, usersJson);
        return;
      }
    }

    usersJson.add(jsonEncode(updatedUser.toJson()));
    await prefs.setStringList(_registeredUsersKey, usersJson);
  }

  // Authenticate user
  Future<User?> authenticate(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> usersJson =
        prefs.getStringList(_registeredUsersKey) ?? [];

    for (String u in usersJson) {
      final user = User.fromJson(jsonDecode(u));
      // Check email OR name
      if ((user.email == email || user.name == email) &&
          user.password == password) {
        return user;
      }
    }
    return null;
  }
}

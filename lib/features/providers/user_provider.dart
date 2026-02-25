import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_share/user_share_pre.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  final UserSharePre _userSharePre = UserSharePre();

  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> loadUser() async {
    _user = await _userSharePre.getUser();
    notifyListeners();
  }

  Future<void> login(User user) async {
    _user = user;
    await _userSharePre.saveUser(user);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await _userSharePre.removeUser();
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    await _userSharePre.saveUser(_user!);
    await _userSharePre.updateRegisteredUser(_user!);
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    if (_user == null || _user!.isDarkMode == isDark) {
      return;
    }

    _user = _user!.copyWith(isDarkMode: isDark);
    notifyListeners();

    try {
      await _userSharePre.saveUser(_user!);
      await _userSharePre.updateRegisteredUser(_user!);
    } catch (_) {}
  }

  void setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/logged_user.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  LoggedUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  LoggedUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> checkSession() async {
    _currentUser = await _repository.getLoggedUser();
    notifyListeners();
  }

  Future<bool> login(String login, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final user = await _repository.login(login, password);

    if (user != null) {
      _currentUser = user;
    } else {
      _errorMessage = 'Usuário ou senha incorretos.';
    }

    _isLoading = false;
    notifyListeners();
    return user != null;
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    notifyListeners();
  }
}

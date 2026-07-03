import 'package:shared_preferences/shared_preferences.dart';
import '../models/logged_user.dart';
import 'employee_repository.dart';

class AuthRepository {
  static const String _keyUserId = 'current_user_id';
  static const String _keyUserName = 'current_user_name';
  static const String _keyUserAdmin = 'current_user_admin';

  static const String _adminUser = 'admin';
  static const String _adminPassword = 'admin123';

  final EmployeeRepository _employeeRepository = EmployeeRepository();

  Future<LoggedUser?> login(String login, String password) async {
    LoggedUser? user;

    if (login.trim().toLowerCase() == _adminUser &&
        password == _adminPassword) {
      user = LoggedUser(
        id: 'admin',
        name: 'Administrador RH',
        isAdmin: true,
      );
    } else if (password.isNotEmpty) {
      final employees = await _employeeRepository.getAll();
      for (final employee in employees) {
        if (employee.email.toLowerCase() == login.trim().toLowerCase() &&
            employee.password == password) {
          user = LoggedUser(
            id: employee.id,
            name: employee.name,
            isAdmin: false,
          );
          break;
        }
      }
    }

    if (user != null) {
      await _saveSession(user);
    }
    return user;
  }

  Future<void> _saveSession(LoggedUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setBool(_keyUserAdmin, user.isAdmin);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserAdmin);
  }

  Future<LoggedUser?> getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    if (id == null) return null;

    final isAdmin = prefs.getBool(_keyUserAdmin) ?? false;
    if (isAdmin) {
      return LoggedUser(
        id: id,
        name: prefs.getString(_keyUserName) ?? '',
        isAdmin: true,
      );
    }

    // Sessão de funcionário: confirma que ele ainda existe no cadastro
    final employees = await _employeeRepository.getAll();
    for (final employee in employees) {
      if (employee.id == id) {
        return LoggedUser(
          id: employee.id,
          name: employee.name,
          isAdmin: false,
        );
      }
    }

    // Funcionário foi excluído: limpa a sessão órfã
    await logout();
    return null;
  }
}

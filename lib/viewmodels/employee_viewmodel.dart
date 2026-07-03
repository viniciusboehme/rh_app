import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/employee.dart';
import '../repositories/employee_repository.dart';

class EmployeeViewModel extends ChangeNotifier {
  final EmployeeRepository _repository = EmployeeRepository();
  final Uuid _uuid = const Uuid();

  List<Employee> _employees = [];
  String _search = '';
  bool _isLoading = false;

  List<Employee> get employees => _employees
      .where((e) => e.name.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  bool get isLoading => _isLoading;

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();
    _employees = await _repository.getAll();
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<bool> _emailAlreadyUsed(String email, {String? exceptId}) async {
    final normalized = email.trim().toLowerCase();
    final all = await _repository.getAll();
    return all.any((e) =>
        e.id != exceptId && e.email.trim().toLowerCase() == normalized);
  }

  Future<bool> addEmployee({
    required String name,
    required String role,
    required String department,
    required String email,
    required String password,
  }) async {
    if (await _emailAlreadyUsed(email)) return false;

    final employee = Employee(
      id: _uuid.v4(),
      name: name,
      role: role,
      department: department,
      email: email.trim(),
      password: password,
    );
    await _repository.save(employee);
    await loadEmployees();
    return true;
  }

  Future<bool> updateEmployee(Employee employee) async {
    if (await _emailAlreadyUsed(employee.email, exceptId: employee.id)) {
      return false;
    }
    await _repository.update(employee);
    await loadEmployees();
    return true;
  }

  Future<void> deleteEmployee(String id) async {
    await _repository.delete(id);
    await loadEmployees();
  }

  int get totalEmployees => _employees.length;

  Map<String, List<Employee>> get employeesByDepartment {
    final map = <String, List<Employee>>{};
    for (final employee in _employees) {
      map.putIfAbsent(employee.department, () => []).add(employee);
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }
}

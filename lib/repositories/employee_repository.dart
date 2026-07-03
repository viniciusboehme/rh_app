import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';

class EmployeeRepository {
  static const String _key = 'employees';

  Future<List<Employee>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((e) => Employee.fromMap(jsonDecode(e)))
        .toList();
  }

  Future<void> save(Employee employee) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.add(employee);
    await prefs.setStringList(
      _key,
      list.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  Future<void> update(Employee updated) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    final index = list.indexWhere((e) => e.id == updated.id);
    if (index != -1) list[index] = updated;
    await prefs.setStringList(
      _key,
      list.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.removeWhere((e) => e.id == id);
    await prefs.setStringList(
      _key,
      list.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }
}

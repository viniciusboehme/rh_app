import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feedback_model.dart';

class FeedbackRepository {
  static const String _key = 'feedbacks';

  Future<List<FeedbackModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((e) => FeedbackModel.fromMap(jsonDecode(e)))
        .toList();
  }

  Future<List<FeedbackModel>> getByEmployee(String employeeId) async {
    final all = await getAll();
    return all.where((f) => f.employeeId == employeeId).toList();
  }

  Future<void> save(FeedbackModel feedback) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.add(feedback);
    await prefs.setStringList(
      _key,
      list.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.removeWhere((f) => f.id == id);
    await prefs.setStringList(
      _key,
      list.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }
}

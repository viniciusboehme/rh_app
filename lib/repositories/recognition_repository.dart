import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recognition.dart';

class RecognitionRepository {
  static const String _key = 'recognitions';

  Future<List<Recognition>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((e) => Recognition.fromMap(jsonDecode(e))).toList();
  }

  Future<List<Recognition>> getRecent({int limit = 10}) async {
    final all = await getAll();
    // A lista é gravada em ordem de criação; invertida = mais recentes
    // primeiro (a data 'dd/MM/yyyy' não serve para ordenar como texto)
    return all.reversed.take(limit).toList();
  }

  Future<List<Recognition>> getByReceiver(String receiverId) async {
    final all = await getAll();
    // Mais recentes primeiro (a lista é gravada em ordem de criação)
    return all
        .where((r) => r.receiverId == receiverId)
        .toList()
        .reversed
        .toList();
  }

  Future<void> save(Recognition recognition) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.add(recognition);
    await prefs.setStringList(
      _key,
      list.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.removeWhere((r) => r.id == id);
    await prefs.setStringList(
      _key,
      list.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }
}

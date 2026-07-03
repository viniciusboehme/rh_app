import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/recognition.dart';
import '../repositories/recognition_repository.dart';

const List<String> recognitionCategories = [
  'Trabalho em Equipe',
  'Inovação',
  'Liderança',
  'Comunicação',
  'Superação',
];

const Map<String, String> categoryEmojis = {
  'Trabalho em Equipe': '🤝',
  'Inovação': '💡',
  'Liderança': '🏆',
  'Comunicação': '💬',
  'Superação': '🚀',
};

class RecognitionViewModel extends ChangeNotifier {
  final RecognitionRepository _repository = RecognitionRepository();
  final Uuid _uuid = const Uuid();

  List<Recognition> _feed = [];
  List<Recognition> _received = [];
  bool _isLoading = false;

  List<Recognition> get feed => _feed;
  List<Recognition> get received => _received;
  bool get isLoading => _isLoading;

  Future<void> loadFeed() async {
    _isLoading = true;
    notifyListeners();
    _feed = await _repository.getRecent(limit: 10);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadReceived(String employeeId) async {
    // Limpa a lista anterior para não exibir dados de outro funcionário
    _received = [];
    _isLoading = true;
    notifyListeners();
    _received = await _repository.getByReceiver(employeeId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendRecognition({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String category,
    required String message,
  }) async {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final recognition = Recognition(
      id: _uuid.v4(),
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      category: category,
      message: message,
      date: date,
    );
    await _repository.save(recognition);
    await loadFeed();
  }

  Future<void> deleteRecognition(String id) async {
    await _repository.delete(id);
    await loadFeed();
  }
}

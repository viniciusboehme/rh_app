import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/feedback_model.dart';
import '../repositories/feedback_repository.dart';

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackRepository _repository = FeedbackRepository();
  final Uuid _uuid = const Uuid();

  List<FeedbackModel> _feedbacks = [];
  bool _isLoading = false;

  List<FeedbackModel> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;

  int get totalCount => _feedbacks.length;

  Future<void> loadFeedbacks(String employeeId) async {
    // Limpa a lista anterior para não exibir dados de outro funcionário
    // enquanto o carregamento não termina
    _feedbacks = [];
    _isLoading = true;
    notifyListeners();
    _feedbacks = await _repository.getByEmployee(employeeId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFeedback({
    required String employeeId,
    required String message,
  }) async {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final feedback = FeedbackModel(
      id: _uuid.v4(),
      employeeId: employeeId,
      message: message,
      date: date,
    );
    await _repository.save(feedback);
    await loadFeedbacks(employeeId);
  }

  Future<void> deleteFeedback(String id, String employeeId) async {
    await _repository.delete(id);
    await loadFeedbacks(employeeId);
  }
}

class FeedbackModel {
  final String id;
  final String employeeId;
  String message;
  final String date;

  // Feedbacks são 100% anônimos: não guardamos quem escreveu
  // nem classificação por tipo.
  FeedbackModel({
    required this.id,
    required this.employeeId,
    required this.message,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'message': message,
      'date': date,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'],
      employeeId: map['employeeId'],
      message: map['message'],
      date: map['date'],
    );
  }
}

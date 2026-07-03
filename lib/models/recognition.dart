class Recognition {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String category;
  final String message;
  final String date;

  Recognition({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.category,
    required this.message,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'category': category,
      'message': message,
      'date': date,
    };
  }

  factory Recognition.fromMap(Map<String, dynamic> map) {
    return Recognition(
      id: map['id'],
      senderId: map['senderId'],
      senderName: map['senderName'],
      receiverId: map['receiverId'],
      receiverName: map['receiverName'],
      category: map['category'],
      message: map['message'],
      date: map['date'],
    );
  }
}

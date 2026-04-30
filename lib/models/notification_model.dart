class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      isRead: json['read'] as bool? ?? false, // FastAPI returns "read" not "is_read"
    );
  }
}
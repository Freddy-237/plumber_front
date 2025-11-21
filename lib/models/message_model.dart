class Message {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime time;
  final String? avatarUrl;

  Message({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.time,
    this.avatarUrl,
  });
}

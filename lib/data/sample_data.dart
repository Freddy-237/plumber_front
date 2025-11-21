import '../models/message_model.dart';

// Liste d'utilisateurs (id, name, avatar)
final List<Map<String, String?>> sampleUsers = [
  {'id': 'u1', 'name': 'Alice', 'avatar': null},
  {'id': 'u2', 'name': 'Bob', 'avatar': null},
  {'id': 'u3', 'name': 'Sam', 'avatar': null},
];

// Messages d'exemple
final List<Message> sampleMessages = [
  Message(
    id: 'm1',
    userId: 'u2',
    userName: 'Bob',
    text: 'Salut, quelqu\'un peut m\'aider ?',
    time: DateTime.now().subtract(const Duration(minutes: 12)),
  ),
  Message(
    id: 'm2',
    userId: 'u1',
    userName: 'Alice',
    text: 'Je suis dispo, quel est le problème ?',
    time: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
  Message(
    id: 'm3',
    userId: 'u3',
    userName: 'Sam',
    text: 'Je peux aussi regarder.',
    time: DateTime.now().subtract(const Duration(minutes: 4)),
  ),
];

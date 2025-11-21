import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/message_model.dart';

class ExportService {
  /// Exporte la liste d'utilisateurs et la liste de messages en fichiers JSON
  /// Retourne une Map avec les chemins des fichiers écrits.
  static Future<Map<String, String>> exportUsersAndMessages({
    required List<Map<String, String?>> users,
    required List<Message> messages,
  }) async {
    final dir = await getApplicationDocumentsDirectory();

    final usersList = users.map((u) => {
          'id': u['id'],
          'name': u['name'],
          'avatar': u['avatar'],
        }).toList();

    final messagesList = messages
        .map((m) => {
              'id': m.id,
              'userId': m.userId,
              'userName': m.userName,
              'text': m.text,
              'time': m.time.toIso8601String(),
              'avatarUrl': m.avatarUrl,
            })
        .toList();

    final usersFile = File('${dir.path}/users.json');
    final messagesFile = File('${dir.path}/messages.json');

    await usersFile.writeAsString(const JsonEncoder.withIndent('  ').convert(usersList));
    await messagesFile.writeAsString(const JsonEncoder.withIndent('  ').convert(messagesList));

    return {
      'users': usersFile.path,
      'messages': messagesFile.path,
    };
  }
}

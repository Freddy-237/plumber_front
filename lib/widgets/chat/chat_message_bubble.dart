import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/message_model.dart';
import '../../services/api_client.dart';
import '../../constants/colors.dart';
import 'chat_avatar.dart';
import 'audio_player_widget.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String? authorRole;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.authorRole,
  });

  @override
  Widget build(BuildContext context) {
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isMe ? const Color.fromARGB(209, 7, 89, 166) : const Color.fromARGB(255, 180, 199, 208);
    final textColor = isMe ? AppColors.secondaryColor : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            ChatAvatar(
              name: message.userName,
              isMe: false,
              role: authorRole,
              avatarUrl: message.avatarUrl,
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.userName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat.Hm().format(message.time),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.only(
                        topLeft: isMe
                            ? const Radius.circular(16)
                            : const Radius.circular(4),
                        topRight: isMe
                            ? const Radius.circular(4)
                            : const Radius.circular(16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    padding: message.replyTo != null
                        ? const EdgeInsets.all(8)
                        : message.isImage
                            ? const EdgeInsets.all(4)
                            : const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                    child: _buildMessageContent(textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Color textColor) {
    debugPrint('🎨 Building message content:');
    debugPrint('   - attachments: ${message.attachments.length}');
    debugPrint('   - isImage: ${message.isImage}');
    debugPrint('   - text: "${message.text}"');
    debugPrint(
        '   - replyTo: ${message.replyTo != null ? "YES (${message.replyTo!.userName})" : "NO"}');

    final List<Widget> contentWidgets = [];

    // Afficher le message auquel on répond (si présent)
    if (message.replyTo != null) {
      debugPrint('   ✅ Affichage du widget de réponse');
      contentWidgets.add(_buildReplyToWidget(message.replyTo!, textColor));
    }

    // Si le message a des attachments, les afficher
    if (message.attachments.isNotEmpty) {
      debugPrint('   ✅ Affichage ${message.attachments.length} attachments');

      // Afficher tous les attachments
      for (var attachment in message.attachments) {
        debugPrint(
            '   📎 Type: ${attachment.mimeType}, URL: ${attachment.url}');

        if (attachment.isImage) {
          // Ajouter un padding si c'est une image et qu'il y a un message de réponse
          final imageWidget = _buildNetworkImageContent(attachment.url);
          if (message.replyTo != null) {
            contentWidgets.add(
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: imageWidget,
              ),
            );
          } else {
            contentWidgets.add(imageWidget);
          }
        } else if (attachment.isAudio) {
          contentWidgets
              .add(_buildNetworkAudioContent(attachment.url, textColor));
        } else {
          contentWidgets.add(_buildFileAttachment(attachment, textColor));
        }
      }

      // Afficher le texte si présent
      if (message.text.isNotEmpty) {
        contentWidgets.add(
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 6),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: contentWidgets,
      );
    }
    // Sinon, afficher selon les anciennes propriétés (pour compatibilité)
    else if (message.isImage && message.imageUrl != null) {
      final imageWidget = _buildNetworkImageContent(message.imageUrl!);
      if (message.replyTo != null) {
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: imageWidget,
          ),
        );
      } else {
        contentWidgets.add(imageWidget);
      }
    } else if (message.isAudio && message.audioUrl != null) {
      contentWidgets
          .add(_buildNetworkAudioContent(message.audioUrl!, textColor));
    } else if (message.text.isNotEmpty) {
      contentWidgets.add(
        Text(
          message.text,
          style: TextStyle(color: textColor, fontSize: 15),
        ),
      );
    }

    // Si on a du contenu à afficher, le retourner dans une Column
    if (contentWidgets.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: contentWidgets,
      );
    }

    // Fallback: message vide
    return Text(
      message.text,
      style: TextStyle(color: textColor, fontSize: 15),
    );
  }

  Widget _buildReplyToWidget(Message replyTo, Color textColor) {
    // Couleur légèrement transparente pour le fond
    final replyBgColor = isMe
        ? AppColors.secondaryColor.withOpacity(0.15)
        : Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: replyBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? AppColors.secondaryColor : const Color.fromARGB(255, 65, 141, 202),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            replyTo.userName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isMe ? AppColors.secondaryColor : const Color.fromARGB(255, 65, 141, 202),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyTo.text.isNotEmpty
                ? replyTo.text
                : replyTo.isImage
                    ? '📷 Image'
                    : replyTo.isAudio
                        ? '🎵 Audio'
                        : 'Message',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isMe
                  ? AppColors.secondaryColor.withOpacity(0.7)
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImageContent(String imageUrl) {
    // Construire l'URL complète si c'est un chemin relatif
    final fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : '${ApiClient.baseUrl}$imageUrl';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        fullUrl,
        width: 250,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 250,
            height: 250,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Erreur chargement image: $fullUrl - $error');
          return Container(
            width: 250,
            height: 200,
            color: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'Image non disponible',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNetworkAudioContent(String audioUrl, Color textColor) {
    debugPrint('🎵 Création AudioPlayerWidget avec URL: "$audioUrl"');
    debugPrint('🎵 URL vide? ${audioUrl.isEmpty}');

    // Utiliser le vrai lecteur audio
    return AudioPlayerWidget(
      audioUrl: audioUrl,
      duration: message.audioDuration,
      iconColor: textColor,
    );
  }

  Widget _buildFileAttachment(Attachment attachment, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file, color: textColor, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              attachment.filename,
              style: TextStyle(color: textColor, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

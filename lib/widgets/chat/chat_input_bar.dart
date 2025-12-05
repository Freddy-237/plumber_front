import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final VoidCallback onRecordAudio;
  final VoidCallback onPickPhoto;
  final bool isRecording;
  final Function(String) onTextChanged;
  final bool isConnected;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSendMessage,
    required this.onRecordAudio,
    required this.onPickPhoto,
    this.isRecording = false,
    required this.onTextChanged,
    this.isConnected = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppColors.primaryColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message...',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 5,
                      onChanged: onTextChanged,
                      onSubmitted: (_) => onSendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: onRecordAudio,
                    icon: Icon(
                      isRecording ? Icons.mic : Icons.mic_none,
                      color: isRecording ? Colors.red : const Color(0xFF00589e),
                    ),
                  ),
                  IconButton(
                    onPressed: onPickPhoto,
                    icon: const Icon(
                      Icons.photo_camera,
                      color: Color(0xFF00589e),
                    ),
                  ),
                  IconButton(
                    onPressed: isConnected ? onSendMessage : null,
                    icon: const Icon(Icons.send),
                    color: isConnected ? const Color(0xFF00589e) : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

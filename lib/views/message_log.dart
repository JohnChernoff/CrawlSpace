import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import '../controllers/message_controller.dart';

class MessageLog extends StatefulWidget {
  final ValueNotifier<IList<Message>> messageNotifier;
  final bool postGame;

  const MessageLog({super.key, required this.messageNotifier, this.postGame = false});

  @override
  State<StatefulWidget> createState() => MessageLogState();
}

class MessageLogState extends State<MessageLog> {
  final ScrollController _scrollController = ScrollController();

  bool _shouldAutoScroll() {
    if (!_scrollController.hasClients) return false;
    const threshold = 100.0; // pixels from bottom
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return (maxScroll - currentScroll) <= threshold;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<IList<Message>>(
      valueListenable: widget.messageNotifier,
      builder: (BuildContext context, IList<Message> messages, Widget? child) {
        final shouldScroll = _shouldAutoScroll();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (shouldScroll) _scrollToBottom();
        });

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: widget.postGame ? 1.0 : 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "[${msg.timestamp}]",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: msg.color ?? const Color.fromRGBO(222, 222, 222, 1), //Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

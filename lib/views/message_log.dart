import 'dart:math' as math;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import '../controllers/message_controller.dart';

class MessageLog extends StatefulWidget {
  final ValueNotifier<IList<Message>> messageNotifier;
  final bool postGame;
  final int? maxLines;

  const MessageLog({super.key, // = const ValueKey('message-log'),
    required this.messageNotifier, this.postGame = false, this.maxLines});

  @override
  State<StatefulWidget> createState() => MessageLogState();
}

class MessageLogState extends State<MessageLog> {
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;


  bool _shouldAutoScroll() {
    if (!_scrollController.hasClients) return false;
    const threshold = 100.0;
    return _scrollController.position.pixels <= threshold;
  }


  void _scrollToLatest() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  @override
  void initState() {
    super.initState(); //print("MessageLogState created");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose(); //print("MessageLogState disposed");
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<IList<Message>>(
      valueListenable: widget.messageNotifier,
      builder: (BuildContext context, IList<Message> messages, Widget? child) {
        if (messages.length > _lastMessageCount && _shouldAutoScroll()) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToLatest();
          });
        }
        _lastMessageCount = messages.length;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: widget.postGame ? 1.0 : 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: ListView.builder(
            reverse: true,
            controller: _scrollController,
            itemCount: math.min((widget.maxLines ?? 999), messages.length),
            itemBuilder: (context, index) {
              final msg = messages[messages.length - 1 - index];
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
                          fontFamily: 'JetBrainsMono',
                          fontSize: 14,
                          height: 1.2,
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

import 'dart:async';
import 'dart:collection';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

class Message {
  final String text;
  final String timestamp;
  final Color? color;

  Message({
    required this.text,
    required this.timestamp,
    this.color,
  });
}

class MessageQueueWorker {
  final ValueNotifier<IList<Message>> messageNotifier = ValueNotifier(const IList.empty());
  final Queue<_QueuedMessage> _queue = Queue();
  bool isProcessing = false;
  Completer processNotifier = Completer();

  void addMsg(Message msg, {int delay = 0}) {
    _queue.add(_QueuedMessage(msg, delay));
    _processQueue(); // Trigger processing if not already running
  }

  void _processQueue() {
    if (isProcessing) return;
    isProcessing = true;
    processNotifier = Completer();
    _run();
  }

  Future<void> _run() async {
    while (_queue.isNotEmpty) {
      final qm = _queue.removeFirst();
      await Future.delayed(Duration(milliseconds: qm.delay));
      messageNotifier.value = messageNotifier.value.add(qm.msg);
    }
    isProcessing = false;
    processNotifier.complete();
  }
}

class _QueuedMessage {
  final Message msg;
  final int delay;
  _QueuedMessage(this.msg, this.delay);
}

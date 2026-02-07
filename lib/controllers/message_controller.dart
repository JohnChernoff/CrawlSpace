import 'dart:async';
import 'dart:collection';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:space_fugue/controllers/fugue_controller.dart';
import 'package:flutter/material.dart';
import 'package:space_fugue/controllers/menu_controller.dart';

class MessageController extends FugueController {
  final msgWorker = MessageQueueWorker();

  MessageController(super.fm);

  void addMsg(String txt, {int delay = 100, bool updateAfter = false, Color color = Colors.white}) {
    msgWorker.addMsg(Message(text: txt, timestamp: fm.starDate(),color: color),delay: delay);
    if (updateAfter) fm.update();
  }

  void addResultMsg(ResultMessage rm, {int delay = 100, bool updateAfter = false, Color? color}) {
    msgWorker.addMsg(Message(text: rm.msg, timestamp: fm.starDate(),
        color: color ?? (rm.success ? Colors.white: Colors.red)),delay: delay);
    if (updateAfter) fm.update();
  }

}

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

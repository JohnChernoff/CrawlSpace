import 'package:flutter/material.dart';
import 'package:space_fugue/fugue_model.dart';
import '../controllers/message_controller.dart';
import '../inputs/menu_input.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

class MenuWidget extends StatefulWidget {
  final FugueModel fm;
  const MenuWidget(this.fm,{super.key});

  @override
  State<StatefulWidget> createState() => MenuWidgetState();
}

class MenuWidgetState extends State<MenuWidget> {
  TextStyle textStyle = const TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    final list = widget.fm.menuController.selectionList;

    return MenuInput(
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 4),
          color: Colors.black,
          borderRadius: BorderRadius.circular(16), // Adds rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Menu Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.fm.menuController.currentMenuTitle,
                style: textStyle.copyWith(
                  fontSize: (textStyle.fontSize ?? 14) + 2, // Slightly larger title
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.2),
                height: 1,
              ),
            ),

            // Menu Items
            Expanded(
              flex: 8,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final isEnabled = list[i].enabled;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Text(
                      "${list[i].letter}: ${list[i].label}",
                      style: TextStyle(
                        color: isEnabled ? Colors.white : Colors.grey,
                        fontSize: textStyle.fontSize,
                        height: 1.5, // Better line spacing
                      ),
                    ),
                  );
                },
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.2),
                height: 1,
              ),
            ),

            // Message Log
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: menuMessageLog(widget.fm.msgController.msgWorker.messageNotifier),
              ),
            ),
          ],
        ),
      ),
      widget.fm,
    );
  }

  Widget menuMessageLog(ValueNotifier<IList<Message>> notifier) {
    return ValueListenableBuilder<IList<Message>>(
        valueListenable: notifier,
        builder: (BuildContext context, IList<Message> messages, Widget? child) =>
            Text(messages.last.text, style: textStyle));
  }

}


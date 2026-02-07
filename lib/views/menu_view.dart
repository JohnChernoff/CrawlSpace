import 'package:flutter/material.dart';
import 'package:space_fugue/fugue_model.dart';
import '../controllers/message_controller.dart';
import '../inputs/menu_input.dart';
import 'message_log.dart';
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
      return MenuInput(Dialog(surfaceTintColor: Colors.green, elevation: 4, shadowColor: Colors.white, backgroundColor: Colors.black, child: Column(children: [
        Text(widget.fm.menuController.currentMenuTitle,style: textStyle),
        Expanded(flex: 8, child: ListView(children: List.generate(list.length, (i) {
          return Text("${list[i].letter}: ${list[i].label}",style: TextStyle(color: list[i].enabled ? Colors.white : Colors.grey));
        }))),
        Expanded(flex: 1, child: menuMessageLog(widget.fm.msgController.msgWorker.messageNotifier))
        //MessageLog(key: const ValueKey('menu_log'), messageNotifier: widget.fm.msgController.msgWorker.messageNotifier, maxLines: 44))
      ])),widget.fm);
  }

  Widget menuMessageLog(ValueNotifier<IList<Message>> notifier) {
    return ValueListenableBuilder<IList<Message>>(
        valueListenable: notifier,
        builder: (BuildContext context, IList<Message> messages, Widget? child) =>
            Text(messages.last.text, style: textStyle));
  }

}


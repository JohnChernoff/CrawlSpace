import 'package:flutter/material.dart';
import 'package:space_fugue/fugue_model.dart';
import '../inputs/menu_input.dart';
import 'message_log.dart';

class MenuWidget extends StatefulWidget {

  final FugueModel fm;

  const MenuWidget(this.fm,{super.key});

  @override
  State<StatefulWidget> createState() => MenuWidgetState();

}

class MenuWidgetState extends State<MenuWidget> {
  @override
  Widget build(BuildContext context) {
      final list = widget.fm.menuController.selectionList;
      return MenuInput(Column(children: [
        Expanded(flex: 8, child: ListView(children: List.generate(list.length, (i) {
          return Text("${list[i].letter}: ${list[i].label}",style: const TextStyle(color: Colors.white));
        }))),
        Expanded(child: MessageLog(messageNotifier: widget.fm.msgWorker.messageNotifier, maxLines: 3))
      ]),widget.fm);
  }

}
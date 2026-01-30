import 'package:flutter/material.dart';
import 'package:space_fugue/ascii_grid.dart';
import 'package:space_fugue/message_log.dart';
import 'fugue_model.dart';

class AsciiView extends StatefulWidget {
  final FugueModel fugueModel;
  const AsciiView(this.fugueModel, {super.key});

  @override
  State<StatefulWidget> createState() => AsciiViewState();
}

class AsciiViewState extends State<AsciiView> {

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child :Container(color: Colors.black, child: MessageLog(messageNotifier: widget.fugueModel.msgWorker.messageNotifier))),
      Expanded(child: Row(children: [
        Expanded(child: Container(color: Colors.black, child: Text(
          widget.fugueModel.scannerText(), style: const TextStyle(color: Colors.greenAccent),
        ))),
        AspectRatio(aspectRatio: 1, child: AsciiGrid(widget.fugueModel)),
        Expanded(child: Container(color: Colors.black, child: Text(
          widget.fugueModel.statusText(), style: const TextStyle(color: Colors.greenAccent),
        )))
      ]))
    ]);
  }
}

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
        Expanded(child: Container(color: Colors.black, child: TextBlockWidget(
          widget.fugueModel.statusText(),
        )))
      ]))
    ]);
  }
}

class TextBlockWidget extends StatelessWidget {
  final List<TextBlock> blocks;

  const TextBlockWidget(this.blocks, {super.key});

  @override
  Widget build(BuildContext context) {
    //print("TextBlockWidget building with blocks: ${blocks.length}");
    List<Widget> lines = [];
    List<Widget> currentLine = [];

    for (final block in blocks) { //print(block.txt);
      currentLine.add(Text(block.txt, style: TextStyle(color: block.color)));

      if (block.newline) { //print("Adding line, len: ${currentLine.length}");
        lines.add(Row(children: currentLine));
        currentLine = [];
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(Row(children: currentLine));
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines,
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:space_fugue/views/message_log.dart';
import '../fugue_model.dart';
import 'ascii_grid.dart';

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
      Expanded(flex: 1, child :Container(color: Colors.black, child: MessageLog(messageNotifier: widget.fugueModel.msgController.msgWorker.messageNotifier))),
      Expanded(flex: 2, child: Row(children: [
        Expanded(child: Container(color: Colors.black, child: TextBlockWidget(
          widget.fugueModel.scannerController.scannerText()
        ))),
        AspectRatio(aspectRatio: 2, child: AsciiGrid(widget.fugueModel)),
        Expanded(child: Container(color: Colors.black, child: Padding(padding: const EdgeInsets.only(left: 8), child: TextBlockWidget(
          widget.fugueModel.scannerController.statusText(),
        ))))
      ]))
    ]);
  }
}

class TextBlockWidget extends StatelessWidget {
  final List<TextBlock> blocks;

  const TextBlockWidget(this.blocks, {super.key});

  @override
  Widget build(BuildContext context) { //print("TextBlockWidget building with blocks: ${blocks.length}");
    List<Widget> lines = [];
    List<Widget> currentLine = [];

    for (final block in blocks) { //print(block.txt);
      currentLine.add(Text(block.txt, style: TextStyle(color: block.color, fontFamily: "JetBrainsMono")));

      if (block.newline) { //print("Adding line, len: ${currentLine.length}");
        lines.add(Row(children: currentLine));
        currentLine = [];
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(Row(children: currentLine));
    }

    return ListView(
        children: lines,
    );
  }

}

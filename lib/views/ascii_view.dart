import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:space_fugue/views/message_log.dart';
import '../controllers/menu_controller.dart';
import '../fugue_model.dart';
import '../inputs/menu_input.dart';
import '../inputs/ship_input.dart';
import 'ascii_grid.dart';
import 'menu_view.dart';

class AsciiView extends StatefulWidget {
  final FugueModel fugueModel;
  const AsciiView(this.fugueModel, {super.key});

  @override
  State<StatefulWidget> createState() => AsciiViewState();
}

class AsciiViewState extends State<AsciiView> {

  @override
  Widget build(BuildContext context) {
    print(widget.fugueModel.menuController.inputStack);
    return widget.fugueModel.menuController.inputMode.showMenu
      ? menuView()
      : buildInputLayer(child: mainView(), fugueModel: widget.fugueModel);
  }

  Widget menuView() {
    return LayoutBuilder(builder: (ctx,bc) {
      double w4 = bc.maxWidth / 4;
      double h4 = bc.maxHeight / 4;
      return Stack(children: [
        mainView(),
        // Blur overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 5),
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
        Positioned(
            left: w4,
            top: h4 / 2,
            child: Container(
              color: Colors.black,
              width: w4 * 2,
              height: h4 * 3 ,
              child: MenuWidget(widget.fugueModel),
            ))
        ]);
    });
  }

  Widget mainView() {
    final fullScreen = widget.fugueModel.menuController.fullscreen;
    return ColoredBox(color: Colors.black,child: Column(children: [
        Expanded(child: Row(children: [
          Expanded(flex: 3, child: MessageLog(key: const ValueKey("main-log"),
            messageNotifier: widget.fugueModel.msgController.msgWorker.messageNotifier)),
          if (!fullScreen) Expanded(child: TextBlockWidget(widget.fugueModel.scannerController.scannerText())),
          if (!fullScreen) Expanded(child: TextBlockWidget(widget.fugueModel.scannerController.statusText()))
        ])),
        if (!fullScreen) Expanded(child: Row(children: [ //const ColoredBox(color: Colors.grey),
          Expanded(child: AspectRatio(aspectRatio: 2, child: AsciiGrid(widget.fugueModel)))
        ]))
      ]));
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
        lines.add(SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: currentLine)));
        currentLine = [];
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(Row(children: currentLine));
    }

    return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white)
        ),
        child: ListView(children: lines)
    );
  }

}

Widget buildInputLayer({required Widget child, required FugueModel fugueModel}) =>
  switch (fugueModel.menuController.inputMode) {
     InputMode.main => ShipInput(child,fugueModel),
     InputMode.menu => MenuInput(child, fugueModel),
     InputMode.planet => MenuInput(child, fugueModel)
};
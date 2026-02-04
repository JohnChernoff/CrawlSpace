import 'package:flutter/material.dart';
import 'package:space_fugue/views/message_log.dart';
import '../controllers/menu_controller.dart';
import '../fugue_model.dart';
import '../inputs/confirm_input.dart';
import '../inputs/hyper_input.dart';
import '../inputs/inventory_input.dart';
import '../inputs/planet_input.dart';
import '../inputs/ship_input.dart';
import '../inputs/shop_input.dart';
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
    return buildInputLayer(child:
    Column(children: [
      Expanded(flex: 1, child :Container(color: Colors.black, child: MessageLog(messageNotifier: widget.fugueModel.msgController.msgWorker.messageNotifier))),
      if (!widget.fugueModel.menuController.fullscreen) Expanded(flex: 2, child: Row(children: [
        Expanded(child: Container(color: Colors.black, child: TextBlockWidget(
            widget.fugueModel.scannerController.scannerText()
        ))),
        AspectRatio(aspectRatio: 2, child: AsciiGrid(widget.fugueModel)),
        Expanded(child: Container(color: Colors.black, child: Padding(padding: const EdgeInsets.only(left: 8), child: TextBlockWidget(
          widget.fugueModel.scannerController.statusText(),
        ))))
      ]))
    ]), fugueModel: widget.fugueModel) ;
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


Widget buildInputLayer({required Widget child, required FugueModel fugueModel}) {
  switch (fugueModel.menuController.inputMode) {
    case InputMode.main:
      return ShipInput(child,fugueModel);
    case InputMode.inventory:
      return InventoryInput(child, fugueModel); //InventoryInput(child);
    case InputMode.planet:
      return PlanetInput(child, fugueModel);
    case InputMode.hyperspace:
      return HyperSpaceInput(child, fugueModel);
    case InputMode.shop:
      return ShopInput(child,fugueModel);
    case InputMode.repair:
    // TODO: Handle this case.
      throw UnimplementedError();
    case InputMode.broadcast:
    // TODO: Handle this case.
      throw UnimplementedError();
    case InputMode.dnaShop:
    // TODO: Handle this case.
      throw UnimplementedError();
    case InputMode.tavern:
    // TODO: Handle this case.
      throw UnimplementedError();
    case InputMode.confirm:
      return ConfirmInput(child, fugueModel);
  }
}
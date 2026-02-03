import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:space_fugue/coord_3d.dart';
import 'package:space_fugue/grid.dart';
import 'package:space_fugue/inputs/confirm_input.dart';
import 'package:space_fugue/inputs/hyper_input.dart';
import 'package:space_fugue/inputs/planet_input.dart';
import 'package:space_fugue/inputs/shop_input.dart';
import '../controllers/menu_controller.dart';
import '../fugue_model.dart';
import '../inputs/ship_input.dart';
import '../ship.dart';
import 'ascii_gridcell_widget.dart';

class AsciiGrid extends StatefulWidget {
  final FugueModel fugueModel;
  const AsciiGrid(this.fugueModel, {super.key});

  @override
  State<StatefulWidget> createState() => _AsciiGridState();
}

class _AsciiGridState extends State<AsciiGrid> {
  late FocusNode _focusNode;
  bool showAllCellsOnZPlane = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx,bc) {
      final playship = widget.fugueModel.playerShip;
      if (playship != null) {
        final map = playship.loc.level.map;
        List<Widget> stacks = [];
        int mapSize = playship.loc.level.map.size;
        final cellWidth = (bc.maxWidth / mapSize) * .75;
        final cellHeight = bc.maxHeight / mapSize * .75;
        final scannedCell =
            widget.fugueModel.playerShip?.targetShip?.loc.cell ??
                widget.fugueModel.scannerController.currentScanSelection;
        for (int y = 0; y < mapSize; y++) {
          for (int x = 0; x < mapSize; x++) {
            final widgets = createStack(x,y,cellHeight/2,map,playship,scannedCell,
                showAllCellsOnZPlane: widget.fugueModel.scannerController.showAllCellsOnZPlane);
            stacks.add(ColoredBox(color: Colors.black, child: Stack(
                alignment: Alignment.center,
                children: List.generate(widgets.length, (depth) {
                  final widget = widgets.elementAt(depth);
                  final z = widget.cell.coord.z;
                  final maxZ = mapSize - 1;
                  final t = maxZ > 0 ? z / maxZ : 0.0;

                  // Scale: 0.3 at Z=0, 1.0 at Z=max
                  //final depthScale = 0.3 + (0.7 * t);

                  final curvedT = math.pow(t, 0.6).toDouble(); // <1 boosts near values
                  final depthScale = 0.35 + 0.65 * curvedT;

                  // Character width estimation (monospace: roughly 0.6 * fontSize)
                  final baseFontSize = cellHeight / 2;
                  final fontSize = baseFontSize * depthScale;
                  final charWidth = fontSize * 0.6;  // monospace char width

                  // Position so:
                  // - Smallest char (Z=0) left edge is at 0
                  // - Largest char (Z=max) right edge is at cellWidth
                  final minCharWidth = (baseFontSize * 0.3) * 0.6;  // smallest char width
                  final maxCharWidth = (baseFontSize * 1.0) * 0.6;  // largest char width

                  // Linear interpolation: at t=0, leftEdge=0; at t=1, leftEdge=cellWidth-maxCharWidth
                  final leftEdge = (cellWidth - maxCharWidth) * t;
                  final xPos = leftEdge + charWidth / 2;  // center of char

                  // Similarly for Y: top at 0, bottom at cellHeight
                  final topEdge = (cellHeight - (baseFontSize * 1.0)) * t;
                  final yPos = topEdge + (fontSize / 2);

                  return Positioned(
                      left: xPos,
                      top: yPos,
                      child: Transform.scale(
                          scale: depthScale,
                          alignment: Alignment.center,
                          child: widget));
                })),
            ));
            }
          }
        return buildInputLayer(child: Container(color: Colors.white, width: bc.maxWidth, height: bc.maxHeight, child:
        GridView.count(
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          crossAxisCount: map.size,
          childAspectRatio: bc.maxWidth / bc.maxHeight,  // Match your rectangle aspect ratio
          children: stacks,
        )
        ),fugueModel: widget.fugueModel);
      }
      return const Text("No ship");
    });
  }
}

List<GridCellWidget> createStack(int x, int y, double size, Grid<GridCell> map, Ship playship, GridCell? scannedCell, {showAllCellsOnZPlane = true}) {
  GridCell closestCell = map.cells[Coord3D(x, y, 0)]!;
  final shipCoord = playship.loc.cell.coord;
  final cellWidgets = <GridCellWidget>[];
  for (int z = 0; z < map.size; z++) {
    final cell = map.cells[Coord3D(x,y,z)]!;
    if (showAllCellsOnZPlane) {
      final color = scannedCell?.coord == cell.coord ? Colors.white : null;
      cellWidgets.add(GridCellWidget(cell,size,playship.loc.level.shipsAt(cell), playship, color: color));
    }
    else {
      if (scannedCell?.coord == cell.coord) { //print("Adding scanned coord: ${cell.coord}");
        cellWidgets.add(GridCellWidget(cell,size,playship.loc.level.shipsAt(scannedCell!), playship, color: Colors.white));
      } else {
        if (shipCoord == cell.coord) {
          closestCell = cell; break;
        }
        else if (!cell.empty(playship.loc.level.map)) {
          if (closestCell.empty(playship.loc.level.map) ||
              shipCoord.distance(cell.coord) < shipCoord.distance(closestCell.coord)) {
            closestCell = cell; //print("Closer cell: $closestCell");
          }
        }
      }
    }
  }

  if (!showAllCellsOnZPlane && (cellWidgets.isEmpty || cellWidgets.first.cell.coord.distance(shipCoord) > closestCell.coord.distance(shipCoord))) {
    cellWidgets.add(GridCellWidget(closestCell,size,playship.loc.level.shipsAt(closestCell), playship));
    //if (cellWidgets.length > 1) print("adding closest coord: ${closestCell.coord}");
  } else {
    cellWidgets.sort((a, b) => a.cell.coord.z.compareTo(b.cell.coord.z)); // IMPORTANT: back → front
  }
  //print("Closest Cell: $closestCell");
  return cellWidgets;
}

Widget buildInputLayer({required Widget child, required FugueModel fugueModel}) {
  switch (fugueModel.menuController.inputMode) {
    case InputMode.main:
      return ShipInput(child,fugueModel);
    case InputMode.inventory:
      return ShipInput(child, fugueModel); //InventoryInput(child);
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


import 'dart:math';
import 'package:flutter/material.dart';
import 'package:space_fugue/coord_3d.dart';
import 'package:space_fugue/grid.dart';
import 'package:space_fugue/inputs/hyper_input.dart';
import 'package:space_fugue/inputs/planet_input.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/system.dart';
import '../controllers/menu_controller.dart';
import '../fugue_model.dart';
import '../inputs/ship_input.dart';

class AsciiGrid extends StatefulWidget {
  final FugueModel fugueModel;
  const AsciiGrid(this.fugueModel, {super.key});

  @override
  State<StatefulWidget> createState() => _AsciiGridState();
}

class _AsciiGridState extends State<AsciiGrid> {
  late FocusNode _focusNode;
  bool showAllCellsOnZPlane = false;

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
    final ship = widget.fugueModel.playerShip;
    if (ship != null) {
      final shipCoord = ship.loc.cell.coord;
      final map = ship.loc.level.map;
      List<Widget> stacks = [];
      int mapSize = ship.loc.level.map.size;
      final scannedCell =
          widget.fugueModel.playerShip?.targetShip?.loc.cell ??
          widget.fugueModel.scannerController.currentScanSelection;
      for (int y = 0; y < mapSize; y++) {
        for (int x = 0; x < mapSize; x++) {
          GridCell closestCell = map.cells[Coord3D(x, y, 0)]!;
          final cellWidgets = <GridWidget>[];
          for (int z = 0; z < mapSize; z++) {
            final cell = map.cells[Coord3D(x, y, z)]!;
            if (showAllCellsOnZPlane) {
              cellWidgets.add(GridWidget(cell, ship.loc.level.shipsAt(closestCell), ship));
            }
            else {
              if (scannedCell?.coord == cell.coord) { //print("Adding scanned coord: ${cell.coord}");
                cellWidgets.add(GridWidget(cell, ship.loc.level.shipsAt(scannedCell!), ship, color: Colors.white));
              } else {
                if (shipCoord == cell.coord) {
                  closestCell = cell; break;
                }
                else if (!cell.empty(ship.loc.level.map)) {
                  if (closestCell.empty(ship.loc.level.map) ||
                      shipCoord.distance(cell.coord) < shipCoord.distance(closestCell.coord)) {
                    closestCell = cell; //print("Closer cell: $closestCell");
                  }
                }
              }
            }
          }
          if (!showAllCellsOnZPlane && (cellWidgets.isEmpty || cellWidgets.first.cell.coord.distance(shipCoord) > closestCell.coord.distance(shipCoord))) {
            cellWidgets.add(GridWidget(closestCell, ship.loc.level.shipsAt(closestCell), ship));
            //if (cellWidgets.length > 1) print("adding closest coord: ${closestCell.coord}");
          } else {
            cellWidgets.sort((a, b) => a.cell.coord.z.compareTo(b.cell.coord.z)); // IMPORTANT: back → front
          }
          //print("Closest Cell: $closestCell");
          stacks.add(Stack(
            alignment: Alignment.center,
            children: cellWidgets,
          ));
        }
      }
      return buildInputLayer(child: Container(color: Colors.black, child: GridView.count(
        crossAxisCount: mapSize,
        children: stacks,
      )),fugueModel: widget.fugueModel);
    }
    return const Text("No ship");
  }
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
    case InputMode.repair:
      // TODO: Handle this case.
      throw UnimplementedError();
    case InputMode.techShop:
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
  }
}

class GridWidget extends StatefulWidget {
  final Color? color;
  final Ship playShip;
  final Set<Ship> ships;
  final GridCell cell;
  const GridWidget(this.cell,this.ships,this.playShip, {super.key, this.color});

  @override
  State<StatefulWidget> createState() => GridWidgetState();
}

class GridWidgetState extends State<GridWidget> {
  @override
  Widget build(BuildContext context) {

    final level = widget.playShip.loc.level;
    final maxZ = level.map.size - 1;
    final z = widget.cell.coord.z;
    final t = z / maxZ; // normalized 0.0 → 1.0
    final depthFactor = 0.3 + 0.7 * t;
    final opacity = 0.35 + 0.65 * t;
    final offsetY = (1 - t) * 24; // stronger offset for ASCII
    final distFromPlayer = widget.cell.coord.distance(widget.playShip.loc.cell.coord);
    final zDistFromPlayer = (widget.cell.coord.z - widget.playShip.loc.cell.coord.z).abs();
    final maxDist = sqrt(3) * level.map.size; // diagonal of grid
    // Normalize 0.0 → 1.0, closer = higher value
    final proximityFactor = 1.0 - (distFromPlayer / maxDist).clamp(0, 1);
    // Color intensity based on proximity
    final textColor = Color.lerp(
        Colors.black,  // far away
        Colors.yellowAccent,      // close
        proximityFactor // * t // but also respect z-depth
    ); //final textColor = Color.lerp(Colors.grey[500], Colors.black, t);

    return LayoutBuilder(builder: (ctx, bc) {
      final cellSize = bc.maxWidth;
      final baseFontSize = cellSize * 0.8; // tweak 0.7–0.9
      final fontSize = baseFontSize * depthFactor;
      return Container(decoration: BoxDecoration(
          //color: Colors.black,
          border: !widget.cell.empty(level.map) && zDistFromPlayer == 0
              ? Border.all(color: Colors.white, width: 1)
              : null
      ), child:  Center(
        child: Opacity(
          opacity: widget.color == null ? opacity : 1,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: Transform.scale(
              scale: depthFactor,
              child: getGridChar(fontSize,textColor!),
            ),
          ),
        ),
      ));
    });
  }

  Widget getGridChar(double fontSize, Color color) {
    //print("GridChar: $color");
    final style = TextStyle(
      fontFamily: 'FixedSys',
      height: 1.0,
      fontSize: fontSize,
      color: widget.color ?? color,
    );
    List<Widget> stack = [];
    final cell = widget.cell;
    if (cell is SectorCell) {
      if (cell.planet != null) stack.add(Text("O",style: style));
      if (cell.nebula > 0 && cell.ionStorm > 0) {
        stack.add(Text("&",style: style));
      } else {
        if (cell.nebula > 0) stack.add(Text("~",style: style));
        if (cell.ionStorm > 0) stack.add(Text("#",style: style));
      }
      if (cell.starClass != null) stack.add(Text("*",style: style));
      if (cell.blackHole) stack.add(Text("-",style: style));
    }
    if (widget.ships.isNotEmpty) {
      stack.add(Text(widget.ships.first.npc ? "h" : "@", style: style));
    }
    return Stack(children: stack);
  }

}

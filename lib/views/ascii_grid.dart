import 'dart:math';
import 'package:flutter/material.dart';
import 'package:space_fugue/coord_3d.dart';
import 'package:space_fugue/grid.dart';
import 'package:space_fugue/inputs/hyper_input.dart';
import 'package:space_fugue/inputs/planet_input.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/system.dart';

import '../fugue_model.dart';
import '../inputs/main_input.dart';

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
      List<Stack> stacks = [];
      int mapSize = ship.loc.level.map.size;
      for (int y = 0; y < mapSize; y++) {
        for (int x = 0; x < mapSize; x++) {
          GridCell closestCell = map.cells[Coord3D(x, y, 0)]!;
          final cells = <GridWidget>[];
          for (int z = 0; z < mapSize; z++) {
            final cell = map.cells[Coord3D(x, y, z)]!;
            if (showAllCellsOnZPlane) {
              cells.add(GridWidget(
                cell,
                map.shipMap[cell] ?? {},
                ship,
              ));
            }
            else {
              if (ship.loc.cell.coord == cell.coord) {
                closestCell = cell; break;
              }
              else if (!cell.empty(ship.loc.level.map)) {
                if (closestCell.empty(ship.loc.level.map) ||
                shipCoord.distance(cell.coord) <= shipCoord.distance(closestCell.coord)) {
                  closestCell = cell; //print("Closer cell: $closestCell");
                }
              }
            }
          }
          //print("Closest Cell: $closestCell");
          // IMPORTANT: back → front
          cells.sort((a, b) => a.cell.coord.z.compareTo(b.cell.coord.z));
          stacks.add(Stack(
            alignment: Alignment.center,
            children: showAllCellsOnZPlane
                ? cells
                : [GridWidget(closestCell, map.shipMap[closestCell] ?? {}, ship,)],
          ));
        }
      }
      return buildInputLayer(child: Container(color: Colors.white, child: GridView.count(
        crossAxisCount: mapSize,
        children: stacks,
      )),fugueModel: widget.fugueModel);
    }
    return const Text("No ship");
  }
}

Widget buildInputLayer({required Widget child, required FugueModel fugueModel}) {
  switch (fugueModel.inputMode) {
    case InputMode.main:
      return MainInput(child,fugueModel);
    case InputMode.inventory:
      return MainInput(child, fugueModel); //InventoryInput(child);
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
  static const asciiStyle = TextStyle(
    fontFamily: 'Courier',
    height: 1.0,
  );
  final Ship playShip;
  final Set<Ship> ships;
  final GridCell cell;
  const GridWidget(this.cell,this.ships,this.playShip, {super.key});

  @override
  State<StatefulWidget> createState() => GridWidgetState();
}

class GridWidgetState extends State<GridWidget> {
  @override
  Widget build(BuildContext context) {

    final level = widget.playShip.loc.level;
    final maxZ = level.map.size - 1;
    final z = widget.cell.coord.z;
    // normalized 0.0 → 1.0
    final t = z / maxZ;
    final depthFactor = 0.3 + 0.7 * t;
    final opacity = 0.35 + 0.65 * t;
    final offsetY = (1 - t) * 24; // stronger offset for ASCII
    final distFromPlayer = widget.cell.coord.distance(widget.playShip.loc.cell.coord);
    final zDistFromPlayer = (widget.cell.coord.z - widget.playShip.loc.cell.coord.z).abs();
    final maxDist = sqrt(3) * level.map.size; // diagonal of grid
    // Normalize 0.0 → 1.0, closer = higher value
    final proximityFactor = 1.0 - (distFromPlayer / maxDist).clamp(0, 1);
    //print("Prox: $proximityFactor");
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
          color: Colors.black,
          border: !widget.cell.empty(level.map) && zDistFromPlayer == 0
              ? Border.all(color: Colors.white, width: 1)
              : null
      ), child:  Center(
        child: Opacity(
          opacity: opacity,
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
      color: color,
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
      stack.add(Text(widget.ships.first.npc
          ? "h"
          : "@",
        style: style,
      ));
    }
    return Stack(children: stack);
  }

}

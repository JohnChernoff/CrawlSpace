import 'dart:math';
import 'package:flutter/material.dart';
import 'package:space_fugue/grid.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/system.dart';

class GridCellWidget extends StatefulWidget {
  final double size;
  final Color? color;
  final Ship playShip;
  final Set<Ship> ships;
  final GridCell cell;
  const GridCellWidget(this.cell,this.size,this.ships,this.playShip, {super.key, this.color});

  @override
  State<StatefulWidget> createState() => GridCellWidgetState();
}

class GridCellWidgetState extends State<GridCellWidget> {
  @override
  Widget build(BuildContext context) {
    final level = widget.playShip.loc.level;
    final maxZ = level.map.size - 1;
    final z = widget.cell.coord.z;
    final t = z / maxZ; // normalized 0.0 → 1.0
    final depthFactor = 0.5 + (0.9 * t);
    final opacity = 0.35 + 0.65 * t;
    //final offsetY = (1 - t) * 24; // stronger offset for ASCII
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
    final baseFontSize = widget.size * 0.8; // tweak 0.7–0.9
    final fontSize = baseFontSize * depthFactor;
    return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration( //color: Colors.black,
        border: !widget.cell.empty(level.map) && zDistFromPlayer == 0
            ? Border.all(color: Colors.black, width: 1) : null
    ), child:  Center(
      child: Opacity(
        opacity: widget.color == null ? opacity : 1,
        child: getGridChar(fontSize,textColor!),
      ),
    ));
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
        if (cell.nebula > 0) stack.add(Text("%",style: style));
        if (cell.ionStorm > 0) stack.add(Text("#",style: style));
      }
      if (cell.starClass != null) stack.add(Text("*",style: style));
      if (cell.blackHole) stack.add(Text("-",style: style));
    }
    if (widget.ships.isNotEmpty) {
      if (widget.ships.first.playship) {
        stack.add(  Text("@", style: style.copyWith(color: Colors.blue)));
      }
      else {
        stack.add(Text("h", style: style));
      }
    }
    return Stack(children: stack);
  }

}

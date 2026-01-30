import 'dart:math';
import 'package:space_fugue/fugue_model.dart';
import 'package:space_fugue/ship.dart';
import 'coord_3d.dart';

class Level {
  GridCell? upperLevel;
  late Grid map;
  Level({this.upperLevel});
}

abstract class GridCell {
  final Coord3D coord; //Set<Ship> ships = {};
  GridCell(this.coord);
  bool empty(Grid grid, {countPlayer = true});
  bool hasShips(Grid grid,{countPlayer = true}) {
    final ships = (grid.shipMap[this] ?? {});
    if (ships.isNotEmpty && (countPlayer || ships.length > 2 || ships.first.npc)) return true;
    return false;
  }

  String toScannerString(Grid grid);
  bool scannable(Grid grid,ScannerMode mode);

  @override
  String toString() {
    return "$coord";
  }
}

class Grid<T extends GridCell> {
  Map<GridCell,Set<Ship>> shipMap = {};
  final int size;
  final Map<Coord3D, T> cells;
  late final List<T> _cellList;

  bool removeShip(Ship ship, {GridCell? cell}) {
    return shipMap.putIfAbsent(cell ?? ship.loc.cell, () => {}).remove(ship);
  }

  bool addShip(Ship ship, GridCell cell) {
    return shipMap.putIfAbsent(cell, () => {}).add(ship);
  }

  Grid(this.size, this.cells)
      : _cellList = cells.values.toList();

  T rndCell(Random rnd, {List<T>? cellList}) {
    final list = cellList ?? _cellList;
    return list[rnd.nextInt(list.length)];
  }

  List<T> getAdjacentCells(T cell, {int distance = 1}) {
    final List<T> list = [];

    for (int x = max(cell.coord.x - distance, 0);
    x <= min(cell.coord.x + distance, size - 1);
    x++) {
      for (int y = max(cell.coord.y - distance, 0);
      y <= min(cell.coord.y + distance, size - 1);
      y++) {
        for (int z = max(cell.coord.z - distance, 0);
        z <= min(cell.coord.z + distance, size - 1);
        z++) {
          final c = Coord3D(x, y, z);
          final neighbor = cells[c];
          if (neighbor != null && c != cell.coord) {
            list.add(neighbor);
          }
        }
      }
    }

    return list;
  }

}
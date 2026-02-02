import 'dart:math';
import 'package:space_fugue/ship.dart';
import 'controllers/scanner_controller.dart';
import 'coord_3d.dart';

class Level {
  GridCell? upperLevel;
  late Grid map;
  Level({this.upperLevel});
  Set<Ship> shipsAt(GridCell cell) => map.shipMap[cell] ?? {};
  Set<Ship> getAllShips() {
    Set<Ship> ships = {};
    for (final cell in map._cellList) {
      final s = shipsAt(cell); if (s.isNotEmpty) ships.addAll(s);
    }
    return ships;
  }
  bool addShip(Ship ship, GridCell cell) {
    return  map.shipMap.putIfAbsent(cell, () => {}).add(ship);
  }
  bool removeShip(Ship ship, {GridCell? cell}) {
    return map.shipMap.putIfAbsent(cell ?? ship.loc.cell, () => {}).remove(ship);
  }
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

  List<T> greedyPath(
      T start,
      T goal,
      int dist,
      int maxSteps,
      Random rnd,
      ) {
    final path = <T>[];
    T current = start;

    for (int i = 0; i < maxSteps; i++) {
      if (current == goal) break;

      final candidates = getAdjacentCells(current, distance: dist);

      // Sort by distance to goal (with noise!)
      candidates.sort((a, b) {
        final da = a.coord.distance(goal.coord) + rnd.nextDouble() * 0.2;
        final db = b.coord.distance(goal.coord) + rnd.nextDouble() * 0.2;
        return da.compareTo(db);
      });

      final next = candidates.first;
      if (path.contains(next)) break; // avoid loops

      path.add(next);
      current = next;
    }

    return path;
  }

}
import 'dart:math';
import 'package:collection/collection.dart';

import 'controllers/scanner_controller.dart';
import 'coord_3d.dart';
import 'hazards.dart';
import 'ship.dart';

enum Domain {hyperspace,system,impulse}

abstract class Level {
  Domain get domain;
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
  final Map<Hazard,double> hazMap = {};
  GridCell(this.coord);
  bool empty(Grid grid, {countPlayer = true});
  bool hasShips(Grid grid,{countPlayer = true}) {
    final ships = (grid.shipMap[this] ?? {});
    if (ships.isNotEmpty && (countPlayer || ships.length > 2 || ships.first.npc)) return true;
    return false;
  }

  void clearHazards() {
    hazMap.clear();
  }

  String toScannerString(Grid grid);
  bool scannable(Grid grid,ScannerMode mode);
  double get hazLevel => hazMap.values.sum;
  bool hasHaz(Hazard h) => hazMap.containsKey(h) && hazMap[h]! > 0;

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

  void growHazard(T cell, Hazard hazard, double strength, Random rnd, {spreadFactor = .25}) {
    cell.hazMap[hazard] = strength;
    double spreadProb = (rnd.nextDouble() * strength) * spreadFactor;
    for (final neighborCell in getAdjacentCells(cell)) {
      if (neighborCell.hazMap[hazard] == 0 && rnd.nextDouble() < spreadProb) {
        double nextStr = rnd.nextDouble() * strength;
        growHazard(neighborCell,hazard,nextStr,rnd);
      }
    }
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

  List<T> greedyPath(T start, T goal, int maxSteps, Random rnd, {int nDist = 1, double minHaz = 0}) {
    final path = <T>[];
    T current = start;

    for (int i = 0; i < maxSteps; i++) {
      if (current == goal) break;

      final candidates = getAdjacentCells(current, distance: nDist);

      // Sort by distance to goal (with noise!)
      candidates.sort((a, b) {
        final da = a.coord.distance(goal.coord) + rnd.nextDouble() * 0.2;
        final db = b.coord.distance(goal.coord) + rnd.nextDouble() * 0.2;
        return da.compareTo(db);
      });

      final next = candidates.firstWhereOrNull((c) => c.hazLevel <= minHaz);
      if (next == null || path.contains(next)) break; // avoid loops
      path.add(next);
      current = next;
    }

    return path;
  }

}
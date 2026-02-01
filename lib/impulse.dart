import 'package:space_fugue/grid.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/system.dart';
import 'controllers/scanner_controller.dart';

class ImpulseCell extends GridCell {
  double nebula, ionStorm, asteroid, gammaRad, wakeTurb;

  ImpulseCell(super.coord, {
    this.nebula = 0,
    this.ionStorm = 0,
    this.asteroid = 0,
    this.gammaRad = 0,
    this.wakeTurb = 0,
  });

  @override
  bool scannable(Grid grid, ScannerMode mode) {
    return true;
  }

  @override
  bool empty(Grid<GridCell> grid, {countPlayer = true}) {
    if (super.hasShips(grid,countPlayer: countPlayer)) return false;
    if (nebula > 0 || ionStorm > 0) return false;
    return true;
  }

  @override
  String toScannerString(Grid<GridCell> grid) {
    StringBuffer sb = StringBuffer(toString());
    for (Ship ship in grid.shipMap[this] ?? {}) {
      sb.write("\n$ship");
    }
    return sb.toString();
  }

}

class ImpulseLevel extends Level {
  ImpulseLevel(Grid<ImpulseCell> cells, SectorCell sector) {
    upperLevel = sector;
    map = cells;
  }
  SectorCell get sector => upperLevel as SectorCell;
}

class ImpulseMap extends Grid<ImpulseCell> {
  ImpulseMap(super.size, super.cells);
}
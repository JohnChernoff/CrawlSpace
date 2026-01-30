import 'package:space_fugue/fugue_model.dart';
import 'package:space_fugue/grid.dart';
import 'package:space_fugue/system.dart';

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
    // TODO: implement empty
    throw UnimplementedError();
  }

  @override
  String toScannerString(Grid<GridCell> grid) {
    // TODO: implement toScannerString
    throw UnimplementedError();
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
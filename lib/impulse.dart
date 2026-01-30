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
import 'package:space_fugue/impulse.dart';
import 'package:space_fugue/system.dart';
import 'grid.dart';

sealed class ShipLocation {
  final Level _level;
  final GridCell _cell;

  Level get level => _level;
  GridCell get cell => _cell;

  bool sameLevel(ShipLocation? loc) {
    if (runtimeType != loc.runtimeType) return false;
    return loc?.level.map == level.map;
  }

  const ShipLocation(this._level,this._cell);
}

class SystemLocation extends ShipLocation {
  @override
  System get level => _level as System;
  @override
  SectorCell get cell => _cell as SectorCell;

  const SystemLocation(super.level, super.cell);

  @override
  String toString() {
    return "System: ${level.name}\nSector: ${cell.coord}";
  }
}

class ImpulseLocation extends ShipLocation {
  final SystemLocation systemLoc;
  @override
  ImpulseLevel get level => _level as ImpulseLevel;
  @override
  ImpulseCell get cell => _cell as ImpulseCell;

  const ImpulseLocation(this.systemLoc, super.level, super.cell);

  @override
  String toString() {
    return "System: ${systemLoc.toString()}\nImpulse: ${cell.coord}";
  }
}

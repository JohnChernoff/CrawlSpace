import 'grid.dart';
import 'impulse.dart';
import 'ship.dart';
import 'system.dart';

sealed class ShipLocation {
  final Level _level;
  final GridCell _cell;
  Domain get domain {
    if (this is SystemLocation) return Domain.system;
    if (this is ImpulseLocation) return Domain.impulse;
    return Domain.hyperspace;
  }
  Level get level => _level;
  GridCell get cell => _cell;
  Set<Ship> get ships => level.shipsAt(cell);
  @override
  bool operator ==(Object other) {
    return other is ShipLocation && other.domain == domain && other.cell.coord == cell.coord;
  }
  @override
  int get hashCode => level.hashCode * cell.hashCode;

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

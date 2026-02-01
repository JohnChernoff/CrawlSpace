import 'package:space_fugue/controllers/fugue_controller.dart';
import 'package:space_fugue/controllers/pilot_controller.dart';
import '../coord_3d.dart';
import '../grid.dart';
import '../location.dart';
import '../ship.dart';
import '../systems/engines.dart';

class MovementController extends FugueController {
  MovementController(super.fm);

  void vectorShip(Ship? ship, Coord3D v) {
    if (ship == null) return;
    moveShip(ship, ship.loc.cell.coord.add(v));
  }

  void moveShip(Ship? ship, Coord3D c, {double baseEnergy = 20}) {
    if (ship == null) return;
    int auts = 0;
    fm.glog("Moving ${ship.name} => $c");
    final l = ship.loc;
    GridCell? destination = l.level.map.cells[c];
    if (destination != null) {
      final dist = l.cell.coord.distance(destination.coord);
      bool moving = false;
      Engine? engine = switch(l) {
        SystemLocation() => ship.subEngine,
        ImpulseLocation() => ship.impEngine,
      };
      if (engine != null) {
        double energyUsed = baseEnergy * (1 / engine.efficiency) * dist;
        moving = ship.burnEnergy(energyUsed);
        if (moving) {
          if (ship.move(destination)) {
            fm.layerTransitController.createAndEnterImpulse();
            auts = 20;
          } else {
            auts = (engine.baseAutPerUnitTraversal * dist).round(); //print("Auts: $auts");
          }
        } else {
          fm.msgController.addMsg("Out of energy");
        }
      } else {
        fm.msgController.addMsg("Error: no engine");
      }
      if (!moving) {
       auts = 10;
      }
    } else {
      auts = 1;
    }
    fm.glog("Moved ship: ${ship.name}");
    fm.pilotController.action(ship.pilot, ActionType.movement,actionAuts: auts);
  }

  void loiter({int auts = 10}) {
    fm.pilotController.action(fm.player, ActionType.movement, actionAuts: auts);
  }

}
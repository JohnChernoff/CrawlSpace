import 'package:space_fugue/controllers/fugue_controller.dart';

import '../coord_3d.dart';
import '../impulse.dart';
import '../ship.dart';

class CombatController extends FugueController {
  CombatController(super.fm);

  void fire(Ship? ship) {
    if (ship != null) {
      Coord3D? target = ship.targetShip?.loc.cell.coord ?? ship.targetCoord;
      if (target == null) {
        fm.msgController.addMsg("Error: no target"); return;
      }
      final cell = ship.loc.level.map.cells[target];
      if (cell is ImpulseCell) { //TODO: sector-ranged weapons?
        double? dam = ship.fireWeapon(cell, fm.rnd, ship: ship.targetShip);
        if (dam != null && ship.targetShip != null) {
          fm.msgController.addMsg("${ship.targetShip} takes $dam damage");
          ship.targetShip!.takeDamage(dam.floor());
        }
      } else {
        fm.msgController.addMsg("Wrong firing level");
      }
    }
  }
}
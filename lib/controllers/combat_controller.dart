import 'package:space_fugue/controllers/fugue_controller.dart';
import 'package:space_fugue/controllers/pilot_controller.dart';
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
        double? dam = ship.fireWeapon(cell, fm.rnd, ship: ship.targetShip); //TODO: determine auts
        if (dam != null && ship.targetShip != null) {
          if (dam > 0) {
            fm.msgController.addMsg("${ship.targetShip} takes $dam damage");
            if (ship.targetShip!.takeDamage(dam)) explode(ship.targetShip!,[ship]);
          }
          else {
            fm.msgController.addMsg("${ship.name} misses!");
          }
          fm.pilotController.action(ship.pilot, ActionType.combat);
        }
      } else {
        fm.msgController.addMsg("Wrong firing level");
      }
    }
  }

  void explode(Ship ship, List<Ship> scanningShips) {
    fm.msgController.addMsg("${ship.name} explodes!");
    for (final cmp in ship.installedSystems.where((s) => s.system != null)) {
      if (fm.rnd.nextBool()) {
        final cell = ship.loc.cell; if (cell is ImpulseCell) {
          cmp.system!.damage = 50.0 + fm.rnd.nextInt(50);
          cell.items.add(cmp.system!);
        }
      }
    }
    fm.pilotMap.remove(ship.pilot);
    ship.loc.level.map.shipMap[ship.loc.cell]?.remove(ship);
    for (final s in scanningShips) {
      s.targetShip = null;
    }
    fm.update();
  }
}
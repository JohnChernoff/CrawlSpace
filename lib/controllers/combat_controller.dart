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
        final result = ship.fireWeapons(cell, fm.rnd, ship: ship.targetShip);
        if (result != null && ship.targetShip != null) {
          if (result.minCool == null && ship == fm.playerShip) {
            fm.msgController.addMsg("No weapons ready");
          }
          else if (result.dmg > 0) {
            fm.msgController.addMsg("${ship.targetShip} takes ${result.dmg} damage");
            if (ship.targetShip!.takeDamage(result.dmg)) explode(ship.targetShip!);
          }
          else {
            fm.msgController.addMsg("${ship.name} misses!");
          }
          fm.pilotController.action(ship.pilot, ActionType.combat, actionAuts: 1); //or result.minCool?
        }
      } else {
        fm.msgController.addMsg("Wrong firing level");
      }
    }
  }

  void explode(Ship ship) {
    fm.msgController.addMsg("${ship.name} explodes!");
    for (final cmp in ship.installedSystems.where((s) => s.system != null)) {
      if (fm.rnd.nextBool()) {
        final cell = ship.loc.cell; if (cell is ImpulseCell) {
          cmp.system!.damage = 50.0 + fm.rnd.nextInt(50);
          cell.items.add(cmp.system!);
        }
      }
    }
    fm.removeShip(ship);
    fm.update();
  }
}
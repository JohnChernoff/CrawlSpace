import 'package:space_fugue/controllers/fugue_controller.dart';
import 'package:space_fugue/controllers/pilot_controller.dart';
import '../agent.dart';
import '../coord_3d.dart';
import '../grid.dart';
import '../impulse.dart';
import '../location.dart';
import '../pilot.dart';
import '../ship.dart';
import '../system.dart';

class LayerTransitController extends FugueController {
  LayerTransitController(super.fm);

  ImpulseLocation? get playerImpulseLoc => pilotImpulseLoc(fm.player);
  ImpulseLocation? pilotImpulseLoc(Pilot p) {
    final l = fm.pilotMap[p]?.loc;
    if (l is ImpulseLocation) {
      return l;
    } else {
      return null;
    }
  }

  void warp(Ship ship) {
    System system = fm.galaxy.getRandomLinkableSystem(
        fm.player.system, ignoreTraffic: true) ?? fm.galaxy.getRandomSystem(fm.player.system);
    if (newSystem(fm.player,system)) {
      //ship.warps.value--;
      fm.msgController.addMsg("*** EMERGENCY WARP ACTIVATED ***");
      if (ship.playship) {
        for (Agent agent in fm.agents) {
          agent.clueLvl = 25;
        }
      }
    }
    fm.pilotController.action(ship.pilot,ActionType.warp);
  }

  bool newSystem(Pilot pilot, System system) {
    if (fm.pilotMap.containsKey(pilot)) {
      Ship ship = fm.pilotMap[pilot]!;
      final sysLoc = ship.loc;
      if (sysLoc is SystemLocation) {
        if (sysLoc.cell.starClass != null) {
          sysLoc.level.removeShip(ship);
          final stars = system.map.cells.values.where((c) => c is SectorCell && c.starClass != null);
          ship.loc = SystemLocation(system, stars.first);
          pilot.system = system;
          fm.pilotController.action(pilot,ActionType.sector);
          return true;
        }
      }
    }
    return false;
  }

  void createAndEnterImpulse({int gridSize = 8, int minDist = 4}) {
    Ship? playShip = fm.playerShip;
    if (playShip == null) {
      fm.msgController.addMsg("You're not in a ship."); return;
    }
    if (playShip.loc is! SystemLocation) {
      fm.msgController.addMsg("Error: ship not at system level"); return;
    }
    fm.glog("Creating impulse map..."); //Entering")
    int size = gridSize; //ship gridsize?
    ImpulseLevel impLevel;
    ShipLocation sysLoc = playShip.loc;
    if (sysLoc is SystemLocation) { //final rnd = Random(l.cell.impulseSeed);
      if (sysLoc.level.impMapCache.containsKey(sysLoc.cell)) {
        impLevel = sysLoc.level.impMapCache[sysLoc.cell]!;
      }
      else {
        Map<Coord3D,ImpulseCell> cells = {};
        for (int x=0;x<size;x++) {
          for (int y=0;y<size;y++) {
            for (int z=0;z<size;z++) {
              final c = Coord3D(x, y, z);
              cells.putIfAbsent(c, () => ImpulseCell(c,
                  wakeTurb: c.isEdge(size) ? 1 : 0
              ));
            }
          }
        }
        impLevel = ImpulseLevel(ImpulseMap(size,cells),sysLoc.cell);
        sysLoc.level.impMapCache.putIfAbsent(sysLoc.cell, () => impLevel);
      }
      _enterImpulse(impLevel,playShip);
      final ships = List.of(sysLoc.ships); //avoids ConcurrentModificationError (hopefully)
      try {
        for (final ship in ships) {
          fm.msgController.addMsg("Dragging ${ship.name} into impulse...");
          if (ship != playShip) _enterImpulse(impLevel,ship);
        }
      } on ConcurrentModificationError {
        fm.glog("fark");
      }
    }
  }

  void _enterImpulse(ImpulseLevel impLvl, Ship? ship, {ImpulseCell? cell, safeDist = 4}) {
    if (ship == null) return;
    final sysLoc = ship.loc;
    if (sysLoc is SystemLocation) {
      GridCell targetCell = cell ?? impLvl.map.rndCell(fm.rnd);
      final pic = playerImpulseLoc;
      if (ship.npc && pic != null && pic.systemLoc.cell == sysLoc.cell && targetCell.coord.distance(pic.cell.coord) < safeDist) {
        List<GridCell> safeDistCells;
        do {
          safeDistCells = impLvl.map.cells.values.where((c) => c.coord.distance(pic.cell.coord) >= safeDist).toList();
          safeDist--;
        } while (safeDistCells.isEmpty);
        safeDistCells.shuffle(fm.rnd);
        targetCell = safeDistCells.first;
      }
      ship.move(targetCell, impLevel: impLvl);
    } //fm.pilotController.action(ship.pilot, ActionType.movement);
  }

  void exitImpulse(Ship? ship) {
    if (ship == null) return;
    final impLoc = ship.loc;
    if (impLoc is ImpulseLocation) {
      if (ship == fm.playerShip) {
        impLoc.level.getAllShips().forEach((s) => _exitImpulse(s, impLoc));
      } else {
        _exitImpulse(ship, impLoc);
      }
      fm.pilotController.action(ship.pilot, ActionType.movement);
    } else {
      fm.msgController.addMsg("Error: ship not at impulse level");
    }
  }

  void _exitImpulse(Ship ship, ImpulseLocation impLoc) {
    impLoc.level.removeShip(ship); //ship.loc = impLoc.systemLoc;
    ship.move(impLoc.systemLoc.cell, toSystem: true);
  }

}
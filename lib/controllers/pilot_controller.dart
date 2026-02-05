import 'dart:math';

import 'package:collection/collection.dart';
import 'package:space_fugue/controllers/fugue_controller.dart';
import 'package:space_fugue/impulse.dart';
import 'package:space_fugue/location.dart';
import 'package:space_fugue/systems/ship_system.dart';
import '../grid.dart';
import '../pilot.dart';
import '../rng.dart';
import '../ship.dart';
import '../systems/weapons.dart';

enum ActionType {
  movement(10,1,1,false),
  sector(32,16,1,false),
  planet(24,24,1,true),
  planetLand(36,50,2,true),
  planetLaunch(16,1,1,false),
  planetOrbit(50,1,1,false),
  warp(8,0,0,false),
  energyScoop(72,0,0,false),
  piracy(100,100,10,false),
  combat(10,1,1,false),
  scrap(5,5,5,false);
  final int baseAuts, risk, heat;
  final bool dna;
  const ActionType(this.baseAuts,this.risk, this.heat, this.dna);
}

class PilotController extends FugueController {
  PilotController(super.fm);

  void action(Pilot? pilot, ActionType actionType, { mod = 1.0, int? actionAuts }) {
    if (pilot == null) return;
    if (pilot == fm.player && actionType.risk > 0 && fm.rnd.nextInt(255) < fm.player.fedLevel()) {
      //msgController.addMsg("You have a bad feeling about this...");
      if (fm.rnd.nextInt(128) < (max(actionType.risk - (actionType.dna ? fm.player.dnaScram : 0),1))) {
        fm.heat(actionType.heat);
      }
    }
    pilot.auCooldown += ((actionAuts ?? actionType.baseAuts) * mod).round();
    pilot.lastAct = actionType;
    fm.update();
    if (pilot == fm.player) runUntilNextPlayerTurn();
  }

  void runUntilNextPlayerTurn() { //fm.glog("Running until next turn...");
    final pilots = List.of(fm.activePilots); // ← Copy the list
    do {
      for (Pilot p in pilots) {
        try {
          p.tick();
          Ship? ship = fm.pilotMap[p];
          if (ship != null && ship.loc.sameLevel(fm.playerShip?.loc)) {
            npcShipAct(ship);
          }
        } on ConcurrentModificationError {
          fm.glog("Skipping: ${p.name}");
        }
      }
      fm.auTick++;
      fm.player.tick();
      fm.playerShip?.tick(fm.rnd);
    } while (!fm.player.ready);
    fm.update();
  }

  void npcShipAct(Ship ship) {
    ship.tick(fm.rnd);
    Pilot? pilot = ship.pilot; if (pilot == null) return;
    if (pilot.ready) {
      final playShip = fm.playerShip;
      //TODO: detect when systems are critical and flee
      if (playShip != null && pilot.hostile && ship.loc.level.getAllShips().contains(playShip)) {
        ship.targetShip = playShip;
        final loc = ship.loc; if (loc is ImpulseLocation) {
            Weapon? w = ship.primaryWeapon; if (w != null && ship.currentShieldPercentage > 50) {
              //print("NPC combat...${w.accuracyRangeConfig.idealRange}, ${ship.distanceFrom(playShip)}");
              if ((w.accuracyRangeConfig.idealRange - ship.distanceFrom(playShip)).abs() > 1) {
                final idealCells = ship.loc.level.map.cells.values
                    .where((c) => playShip.distanceFromCoord(c.coord) < 1)
                    .sorted((c1,c2) => ship.distanceFromCoord(c2.coord).compareTo(ship.distanceFromCoord(c1.coord)));
                ship.currentPath = ship.loc.level.map.greedyPath(ship.loc.cell, idealCells.first, 3, fm.rnd);
              } else {
                if (w.cooldown == 0) {
                  fm.combatController.fire(ship);
                } else {
                  fm.pilotController.action(pilot, ActionType.combat, actionAuts: 1);
                }
                return;
              }
            } else {
              fm.msgController.addMsg("${ship.name} flees!");
              final idealCells = ship.loc.level.map.cells.values
                  .sorted((c1,c2) => playShip.distanceFromCoord(c2.coord).compareTo(playShip.distanceFromCoord(c1.coord)));
              ship.currentPath = ship.loc.level.map.greedyPath(ship.loc.cell, idealCells.first, 3, fm.rnd);
            }
        }
      }
      if (ship.currentPath.isNotEmpty) {
        fm.movementController.moveShip(ship, ship.currentPath.removeAt(0).coord);
      } else {
        fm.movementController.vectorShip(ship, Rng.rndUnitVector(fm.rnd));
      }
    }
  }

  void headTowards(GridCell cell) {

  }
}


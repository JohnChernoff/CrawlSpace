import 'dart:math';

import 'package:space_fugue/controllers/fugue_controller.dart';
import '../pilot.dart';
import '../rng.dart';
import '../ship.dart';

enum ActionType {
  movement(10,1,1,false),
  sector(32,16,1,false),
  planet(24,24,1,true),
  planetLand(36,50,2,true),
  planetLaunch(16,1,1,false),
  planetOrbit(50,1,1,false),
  warp(8,0,0,false),
  energyScoop(72,0,0,false),
  piracy(100,100,10,false);
  final int baseAuts, risk, heat;
  final bool dna;
  const ActionType(this.baseAuts,this.risk, this.heat, this.dna);
}

class PilotController extends FugueController {
  PilotController(super.fm);

  void action(Pilot? pilot, ActionType actionType, { mod = 1.0, int? actionAuts }) {
    if (pilot == null) return;
    if (actionType.risk > 0 && fm.rnd.nextInt(255) < fm.player.fedLevel()) { //msgController.addMsg("You have a bad feeling about this...");
      if (fm.rnd.nextInt(128) < (max(actionType.risk - (actionType.dna ? fm.player.dnaScram : 0),1))) {
        fm.heat(actionType.heat);
      }
    }
    pilot.auCooldown += ((actionAuts ?? actionType.baseAuts) * mod).round();
    pilot.lastAct = actionType;
    fm.update();
    if (pilot == fm.player) runUntilNextPlayerTurn();
  }

  void runUntilNextPlayerTurn() {
    fm.glog("Running until next turn...");
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
      fm.playerShip?.tick();
    } while (!fm.player.ready);
    fm.update();
  }

  void npcShipAct(Ship ship) {
    ship.tick();
    Pilot? pilot = ship.pilot; if (pilot == null) return;
    if (pilot.ready) {
      fm.movementController.vectorShip(ship, Rng.rndUnitVector(fm.rnd));
    }
  }
}


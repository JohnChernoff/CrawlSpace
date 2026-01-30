import 'package:space_fugue/fugue_model.dart';
import 'package:space_fugue/player.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/system.dart';
import 'actions.dart';
import 'main.dart';
import 'options.dart';

class FugueController {
  FugueModel fm;
  FugueController(this.fm);

  void goLink(System system) {
    fm.newTrack(MusicalMood.space);
    if (!fm.player.system.links.contains(system)) {
      fm.addMsg("You can't get there yet.");
    } else {
      if (fm.player.planet != null) { //addMsg("You must first take off.");
        fm.launch();
      }
      if (fm.newSystem(fm.player,system)) {
        if (system.starOne) {
          fm.player.starOne = true;
          fm.addMsg("Star One located!  Proceed to ${fm.galaxy.systems.first.name}.");
        }
        system.visited = true; //TODO: check for agents?
        if (!fm.gameOver && fugueOptions.getBool(FugueOption.autoScoop)) {
          fm.energyScoop();
        }
      } else {
        fm.outOfEnergy();
      }
    }
  }

  void warp() {
    Ship? ship = fm.playerShip;
    if (ship == null) {
      fm.addMsg("You're not in a ship."); return;
    }
    if (ship.energy < ship.warpEngine) {
      ship.energy = ship.warpEngine;
      if (ship.takeDamage(fm.rnd.nextInt(ship.warpEngine))) {
        fm.endGame("Blown up trying to warp"); return;
      }
    }
    if (ship.warps.value > 0) {
      fm.warp(ship);
    } else {
      fm.addMsg("Out of emergency warps.");
    }
  }

  void bioHack({int amount = 1}) {
    if (fm.player.dnaScram < Player.maxDna) {
      if (fm.player.credits >= fm.costBioHack) {
        fm.player.credits -= fm.costBioHack;
        fm.player.dnaScram++;
        fm.addMsg("Dna scrambled (mutation: ${fm.player.dnaScram})");
        fm.pilotAction(fm.player,ActionType.planet,mod: 2);
      } else {
        fm.addMsg("You can't afford this (cost: ${fm.costBioHack} credits).");
      }
    } else {
      fm.addMsg("Your system cannot handle further modification.");
    }
  }

  void shoplift() {
    if (fm.player.planet == null) return;
    bool success = fm.rnd.nextInt(300) < (fm.player.thievery + 200);
    if (success) {
      int n = ((fm.player.techLevel()/3) + (fm.player.planet!.commLvl.index * 12)).floor();
      int c = fm.rnd.nextInt(n);
      fm.player.credits += c;
      fm.addMsg("You stole $c credits.");
      fm.pilotAction(fm.player,ActionType.planet);
    }
    else {
      fm.heat((2 * (fm.player.fedLevel()/12)).ceil());
      int penalty = fm.rnd.nextInt(67) + 33;
      int t = fm.rnd.nextInt(3) + 2;
      fm.addMsg("You've been caught!  Penalty: $penalty credits and $t turns in jail.");
      fm.player.credits -= penalty;
      if (fm.player.credits < 0) {
        int t2 = (fm.player.credits.abs() / 20).ceil();
        fm.addMsg("You can't afford the fine! Penalty: $t2 extra turns in jail.");
        fm.player.credits = 0;
      }
      fm.pilotAction(fm.player,ActionType.planet,actionAuts: t * 100);
    }
  }
}
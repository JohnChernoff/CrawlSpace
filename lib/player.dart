import 'package:space_fugue/options.dart';
import 'package:space_fugue/planet.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/system.dart';

class TradeTarget {
  Planet planet;
  Planet? source;
  int reward;
  TradeTarget(this.planet,this.source,this.reward);
}

enum ActionType {
  sector(32,16,1,false),
  planet(24,24,1,true),
  planetLand(36,50,2,true),
  planetLaunch(16,1,1,false),
  planetOrbit(0,1,1,false), //subTurns not used (~50)
  warp(8,0,0,false),
  energyScoop(72,0,0,false),
  piracy(100,100,10,false);
  final int subTurns, risk, heat;
  final bool dna;
  const ActionType(this.subTurns,this.risk, this.heat, this.dna);
}

enum OrbitResult {newOrbit,sameOrbit,insufficientEnergy}

class Player {
  static const maxDna = 36;
  String name;
  System system;
  Planet? planet;
  Planet? orbiting;
  Ship ship = Ship("HMS Sebastian");
  int credits = 100;
  int dnaScram = 5;
  int subTurnCounter = 0;
  TradeTarget? tradeTarget;
  bool landed = false;
  bool starOne = false;
  int thievery = 25; //200-300
  int broadcasts = 0;
  int piratesEncountered = 0;
  int piratesVanquished = 0;
  ActionType lastAct = ActionType.sector;

  Player(this.name,this.system);

  int action(ActionType actionType, {double modifier = 1, int? subTurns}) {
    lastAct = actionType;
    int turns = 0;
    if (subTurns != null) {
      subTurnCounter += subTurns;
    } else {
      num t = actionType == ActionType.planetOrbit
          ? ship.subTurnsToPlanet(planet) : actionType.subTurns;
      subTurnCounter += (t * modifier).floor();
    }
    while (subTurnCounter > 100) {
      subTurnCounter -= 100; turns++;
    }
    return turns;
  }

  int fedLevel() => planet?.fedLvl ?? system.fedLvl;
  int techLevel() => planet?.techLvl ?? system.techLvl;

  bool newSystem(System sys, {bool warp = false}) {
    int energy = warp ? ship.warpEngine : ship.hyperspaceEngine;
    if (ship.energy >= energy) {
      system = sys;
      orbiting = null; //player.planet should already be null here
      ship.energy -= energy;
      return true;
    } return false;
  }

  OrbitResult newOrbit(Planet? plan) {
    if (orbiting != plan) {
      if (ship.energy < ship.subLightEngine) {
        return OrbitResult.insufficientEnergy;
      }
      planet = plan;
      orbiting = planet;
      ship.energy -= ship.subLightEngine;
      return OrbitResult.newOrbit;
    } else {
      planet = plan;
      return OrbitResult.sameOrbit;
    }
  }
}
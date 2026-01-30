import 'package:space_fugue/pilot.dart';
import 'package:space_fugue/planet.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/system.dart';

class TradeTarget {
  Planet planet;
  Planet? source;
  int reward;
  TradeTarget(this.planet,this.source,this.reward);
}

enum OrbitResult {newOrbit,sameOrbit,insufficientEnergy,noShip}

class Player extends Pilot {
  static const maxDna = 36;
  System system;
  Planet? planet;
  Planet? orbiting;
  int credits = 100;
  int dnaScram = 5;
  TradeTarget? tradeTarget;
  bool landed = false;
  bool starOne = false;
  int thievery = 25; //200-300
  int broadcasts = 0;
  int piratesEncountered = 0;
  int piratesVanquished = 0;
  Set<Ship> fleet = {};

  Player(super.name,this.system, {super.hostile = false});

  int fedLevel() => planet?.fedLvl ?? system.fedLvl;
  int techLevel() => planet?.techLvl ?? system.techLvl;

}
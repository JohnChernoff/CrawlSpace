import 'dart:math';
import 'dart:ui';
import 'package:space_fugue/galaxy.dart';
import 'package:space_fugue/planet.dart';
import 'package:space_fugue/player.dart';

enum WeaponType {
  lasers("laser",50,80,0,0,Color(0xFFFFFF00)),
  plasma("plasma",175,20,0,0,Color(0xFFFF0000)),
  photonTorpedos("photon torpedo",100,50,25,12,Color(0xFF008888));
  final Color color;
  final String name;
  final int damage,accuracy,ammoCost,ammoCap;
  const WeaponType(this.name,this.damage,this.accuracy,this.ammoCost,this.ammoCap,this.color);
}

enum ShipSystemType {
  speed(1,100,50,"Thrusters",Color(0xFFFF9000)),
  weapons(1,100,48,"Lasers",Color(0xFFFFFF00)),
  shields(1,100,72,"Shields",Color(0xFF0000FF)),
  hull(24,100,36,"Hull Integrity",Color(0xFF654321)),
  cargo(8,100,25,"Cargo Capacity",Color(0xFFAAAAAA)),
  battery(36,1024,8,"Energy Capacity",Color(0xFF00FF88)),
  energyConvertor(1,100,12,"Photonic Converter",Color(0xFF00AAFF)),
  warps(1,9,5000,"Emergency Warps",Color(0xFFFFFFFF));
  final int min,max,cost;
  final String name;
  final Color color;
  const ShipSystemType(this.min,this.max,this.cost,this.name, this.color);
}

class ShipSystem {
  final ShipSystemType type;
  int value;
  ShipSystem(this.type,this.value);
  int min() => type.min;
  int max() => type.max;
  int modify(int amount) {
    int prevVal = value;
    value += amount;
    if (value < min()) {
      value = min();
    } else if (value > max()) {
      value = max();
    }
    return value - prevVal;
  }
}

class Ship {
  String name;
  ShipSystem speed = ShipSystem(ShipSystemType.speed, 25);
  ShipSystem cargo = ShipSystem(ShipSystemType.cargo, 12);
  ShipSystem battery = ShipSystem(ShipSystemType.battery, 500);
  ShipSystem energyConvertor = ShipSystem(ShipSystemType.energyConvertor, 33);
  ShipSystem warps = ShipSystem(ShipSystemType.warps, 2);
  ShipSystem weapons = ShipSystem(ShipSystemType.weapons,0);
  ShipSystem shields = ShipSystem(ShipSystemType.shields,0);
  ShipSystem hull = ShipSystem(ShipSystemType.hull,0);
  WeaponType weaponType;
  int energy = 0, damage = 0;
  int subLightEngine, hyperspaceEngine, warpEngine;

  Ship(this.name, {this.subLightEngine = 36,this.hyperspaceEngine = 12,this.warpEngine = 72,
    weapons = 25, shields = 25, hull = 36, this.weaponType = WeaponType.lasers}) {
    energy = battery.value;
    this.weapons.value = weapons;
    this.shields.value = shields;
    this.hull.value = hull;
  }

  List<ShipSystem> systems() {
    return [speed,weapons,shields,hull,cargo,battery,energyConvertor,warps];
  }

  double subTurnsToPlanet(Planet? planet,{minPercent = 0.25, maxPercent = 1.5}) {
    return speedPercent(minPercent: minPercent,maxPercent: maxPercent) *
        (planet != null ? planet.distance : ActionType.planetOrbit.subTurns);
  }

  double speedPercent({minPercent = 0.25,maxPercent = 1.5}) {
    double t = (speed.value - speed.min()) / (speed.max() - speed.min()); // Normalize to 0..1
    double inverseT = 1 - t; // Invert it
    return (minPercent + (maxPercent - minPercent) * inverseT);
  }

  int repair(int amount) {
    int prevDam = damage;
    damage = max(damage - amount,0);
    return prevDam - damage;
  }

  int repairAll() => repair(damage);

  int recharge(int amount) {
    int prevCharge = energy;
    energy = min(energy + amount,battery.value);
    return energy - prevCharge;
  }

  int rechargeAll() => recharge(battery.value - energy);

  bool takeDamage(int dam) {
    damage += dam;  return damage >= hull.value;
  }

  String damageReport() {
    return "${hull.value - damage} hull remaining";
  }

  int fireWeapon(Galaxy galaxy) {
    double weaponQuality = weapons.value / weapons.max();
    int maxDam = (weaponType.damage * weaponQuality).floor();
    return galaxy.biasedRndInt(mean: (maxDam/3).floor(), min: 1, max: maxDam); //TODO: add skill(s)?
  }

  String status({int ? currentShields}) {
    return "$name: ${hull.value} hull, ${currentShields ?? shields.value} shields";
  }
}
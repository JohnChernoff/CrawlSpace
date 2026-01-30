import 'dart:math';
import 'dart:ui';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:space_fugue/coord_3d.dart';
import 'package:space_fugue/engines.dart';
import 'package:space_fugue/pilot.dart';
import 'package:space_fugue/player.dart';
import 'package:space_fugue/shields.dart';
import 'package:space_fugue/system.dart';
import 'package:space_fugue/weapons.dart';
import 'impulse.dart';
import 'item.dart';
import 'location.dart';

enum ShipSystemType {
  hull(24,100,36,"Hull Integrity",Color(0xFF654321)),
  cargo(8,100,25,"Cargo Capacity",Color(0xFFAAAAAA)),
  battery(36,1024,8,"Energy Capacity",Color(0xFF00FF88)),
  energyConvertor(1,100,12,"Photonic Converter",Color(0xFF00AAFF)),
  warps(1,9,5000,"Emergency Warps",Color(0xFFFFFFFF));
  final int min,max,baseCost;
  final String name;
  final Color color;
  const ShipSystemType(this.min,this.max,this.baseCost,this.name,this.color);
}

class ShipSystem1 {
  final ShipSystemType type;
  int value;
  ShipSystem1(this.type,this.value);
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
  Pilot? pilot;
  Pilot owner;
  ShipSystem1 cargo = ShipSystem1(ShipSystemType.cargo, 12);
  ShipSystem1 battery = ShipSystem1(ShipSystemType.battery, 500);
  ShipSystem1 energyConvertor = ShipSystem1(ShipSystemType.energyConvertor, 33);
  ShipSystem1 warps = ShipSystem1(ShipSystemType.warps, 2);
  ShipSystem1 hull = ShipSystem1(ShipSystemType.hull,0);
  Weapon weapon = stockWeapons[StockWeapon.basicLaser]!;
  Shield shield = stockShields[StockShield.basicEnergon]!;
  ImpulseEngine impEngine = stockImpulseEngines[StockImpulseEngine.basicFed]!;
  int energy = 0, damage = 0;
  int subLightEngine, hyperspaceEngine, warpEngine;
  ShipLocation loc;
  int impulseMapSize = 8;
  Set<Item> inventory = {};
  bool get npc => pilot is! Player;

  Ship(this.name, this.owner, {required this.loc, bool vacant = false,
    this.subLightEngine = 36,this.hyperspaceEngine = 12,this.warpEngine = 72,
    weapons = 25, shields = 25, hull = 36}) {
    if (!vacant) pilot = owner;
    energy = battery.value;
    this.hull.value = hull;
    inventory.add(weapon); inventory.add(shield); inventory.add(impEngine);
    loc.level.map.addShip(this,loc.cell);
  }

  double hullPercent() => 1.0 - (damage / hull.value);
  double energyPercent() => energy / battery.value;

  List<ShipSystem1> systems() {
    return [hull,cargo,battery,energyConvertor,warps];
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

  double? fireWeapon(ImpulseCell target, Random rnd) {
    final l = loc;
    if (l is ImpulseLocation) {
      return weapon.fire(l.cell.coord.distance(target.coord), rnd, targetShip: l.level.map.shipMap[target]?.first); //multiple ships at loc?
    } return null;
  }

  String status({int ? currentShields}) {
    return "$name: ${hull.value} hull, ${currentShields ?? shield.strength} shields";
  }

}
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:space_fugue/coord_3d.dart';
import 'package:space_fugue/fugue_model.dart';
import 'package:space_fugue/pilot.dart';
import 'package:space_fugue/player.dart';
import 'package:space_fugue/stock_items/stock_engines.dart';
import 'package:space_fugue/stock_items/stock_shields.dart';
import 'package:space_fugue/stock_items/stock_ships.dart';
import 'package:space_fugue/stock_items/stock_weapons.dart';
import 'package:space_fugue/systems/engines.dart';
import 'package:space_fugue/systems/power.dart';
import 'package:space_fugue/systems/shields.dart';
import 'package:space_fugue/stock_items/stock_power.dart';
import 'package:space_fugue/systems/ship_system.dart';
import 'package:space_fugue/systems/weapons.dart';
import 'grid.dart';
import 'impulse.dart';
import 'item.dart';
import 'location.dart';
import 'package:flutter/material.dart';

class HullResistance {
  final DamageType dmgType;
  final double resistance;
  const HullResistance(this.dmgType,this.resistance);
}

class InstalledSystem {
  SystemSlot slot;
  ShipSystem? system;
  InstalledSystem(this.slot,this.system);
}

class FireResult {
  double dmg;
  int? minCool;
  bool ammoWarn;
  FireResult(this.dmg,this.minCool,this.ammoWarn);
}

class Scrap extends Item {
  double mass;
  bool jettisonable;
  Scrap(super.name, {
    required this.mass,
    this.jettisonable = true,
    required super.baseCost,
    super.rarity = .01
  });
  double get costEffectiveness => baseCost / mass;
}

class Ship {
  ShipClass shipClass;
  String name;
  Pilot? pilot;
  Pilot owner;
  List<InstalledSystem> installedSystems = []; //rename to shipSlots?
  Map<Ammo,int> ammoMap = {};
  double hullDamage = 0;
  ShipLocation loc;
  int impulseMapSize = 8;
  Set<Item> inventory = {};
  bool get playship => pilot is Player;
  bool get npc => !playship;
  Ship? targetShip;
  Ship? interceptShip;
  Coord3D? targetCoord;
  Coord3D? interceptCoord;
  List<GridCell> currentPath = [];
  List<Scrap> scrapHeap = [];

  Ship(this.name, this.owner, {
    required this.shipClass,
    required this.loc,
    PowerGenerator? generator,
    List<Weapon>? weapons,
    Shield? shield,
    Engine? impEngine,
    Engine? subEngine,
    Engine? hyperEngine,
    //TODO: more engines
    bool vacant = false}) {

    if (!vacant) pilot = owner;
    for (final classSlot in shipClass.slots) {
      for (int i=0;i<classSlot.num;i++) {
        installedSystems.add(InstalledSystem(classSlot.slot,null));
      }
    }
    generator ??= PowerGenerator.fromStock(StockPower.basicNuclear);
    hyperEngine ??= Engine.fromStock(StockEngine.basicFedHyperdrive);
    subEngine ??= Engine.fromStock(StockEngine.basicFedSublight);
    impEngine ??= Engine.fromStock(StockEngine.basicFedImpulse);
    shield ??= Shield.fromStock(StockShield.basicEnergon);
    weapons ??= [Weapon.fromStock(StockWeapon.plasmaCannon)];

    inventory.add(generator);
    installSystem(generator);

    inventory.add(hyperEngine);
    installSystem(hyperEngine);
    hyperEngine.active = false;

    inventory.add(subEngine);
    installSystem(subEngine);

    inventory.add(impEngine);
    installSystem(impEngine);
    impEngine.active = false;

    inventory.add(shield);
    installSystem(shield);

    for (final w in weapons) {
      inventory.add(w);
      installSystem(w);
    }

    loc.level.addShip(this,loc.cell);
  }

  Iterable<ShipSystem> get getAllInstalledSystems {
    return installedSystems.where((s) => (s.system != null)).map((i) => i.system!);
  }

  Iterable<ShipSystem> getInstalledSystems(List<ShipSystemType> types) {
    return installedSystems.where((s) => types.contains(s.system?.type)).map((i) => i.system!);
  }

  bool installSystem(ShipSystem s) {
    final availableSlots = installedSystems.where((i) => i.system == null && i.slot.supports(s));
    if (availableSlots.isNotEmpty) {
      availableSlots.first.system = s;
      return true;
    }
    return false;
  }

  double get scrapVal => scrapHeap.fold<double>(0.0, (sum, i) => sum + i.baseCost);

  bool addScrap(ShipSystem s) {
    double m = s.mass/ 20; //TODO: some ship system to improve this?
      if (availableMass > m) {
        scrapHeap.add(Scrap("scrapped ${s.name}", mass: m, baseCost: (s.baseCost / 100).round()));
        return true;
      } return false;
  }

  Scrap? jettisonScrap() {
    if (scrapHeap.isNotEmpty) {
      scrapHeap.sort((a,b) => a.costEffectiveness.compareTo(b.costEffectiveness));
      return scrapHeap.removeAt(0);
    }
    return null;
  }

  double distanceFrom(Ship ship) => ship.loc.cell.coord.distance(loc.cell.coord);
  double distanceFromCoord(Coord3D c) => c.distance(loc.cell.coord);

  double get hullRemaining  => (hullStrength-hullDamage);
  bool get intact => hullRemaining > 0;

  double get currentHullPercentage {
    double s = hullStrength;
    return (s > 0 ? hullRemaining/s : 0) * 100;
  }

  double get currentShieldPercentage {
    double s = currentMaxShieldStrength;
    return (s > 0 ? currentShieldStrength/s : 0) * 100;
  }

  double get currentEnergyPercentage {
    double s = getCurrentMaxEnergy();
    return (s > 0 ? getCurrentEnergy()/s : 0) * 100;
  }

  double get currentMaxShieldStrength {
    double e = 0;
    for (final shield in getInstalledSystems([ShipSystemType.shield])) {
      if (shield is Shield && shield.active) {
        e = shield.currentMaxEnergy; if (shield.currentEnergy > 0) return e;
      }
    }
    return e;
  }

  double get currentShieldStrength => getCurrentShield?.currentEnergy ?? 0;
  Shield? get getCurrentShield {
    for (final shield in getInstalledSystems([ShipSystemType.shield])) {
      if (shield is Shield && shield.active) {
        if (shield.currentEnergy > 0) return shield;
      }
    }
    return null;
  }

  Iterable<Weapon> get availableWeapons {
    return getInstalledSystems([ShipSystemType.weapon]).where((w) => w is Weapon && w.active).map((s) => s as Weapon);
  }

  Iterable<Weapon> get readyWeapons {
    return availableWeapons.where((w) => w.cooldown == 0);
  }

  bool burnEnergy(double e) {
    for (final gen in getInstalledSystems([ShipSystemType.power])) {
      if (gen is PowerGenerator && gen.active && gen.burn(e,partial: false) > 0) { //print("Burning: $e");
        return true;
      }
    }
    return false;
  }

  double getCurrentMaxEnergy({bool raw = false}) {
    double e = 0;
    for (final gen in getInstalledSystems([ShipSystemType.power])) {
      if (gen is PowerGenerator && gen.active) {
        e += (raw ? gen.rawMaxEnergy : gen.currentMaxEnergy);
      }
    }
    return e;
  }

  double getCurrentEnergy({bool raw = false}) {
    double e = 0;
    for (final gen in getInstalledSystems([ShipSystemType.power])) {
      if (gen is PowerGenerator && gen.active) {
        e += (raw ? gen.rawEnergy : gen.currentEnergy);
      }
    }
    return e;
  }

  Engine? get impEngine => getInstalledSystems([ShipSystemType.engine]).whereType<Engine>().where((w) => w.domain == EngineDomain.impulse).firstOrNull;
  Engine? get subEngine => getInstalledSystems([ShipSystemType.engine]).whereType<Engine>().where((w) => w.domain == EngineDomain.sublight).firstOrNull;
  Engine? get hyperEngine => getInstalledSystems([ShipSystemType.engine]).whereType<Engine>().where((w) => w.domain == EngineDomain.hyperspace).firstOrNull;

  double repairHull(double amount) {
    double prevDam = hullDamage;
    hullDamage = max(hullDamage - amount,0);
    return prevDam - hullDamage;
  }

  //int repairAll() { return; }

  double recharge(double energy) {
    for (final gen in getInstalledSystems([ShipSystemType.power])) {
      if (gen is PowerGenerator && gen.active) {
        energy -= gen.recharge(energy);
      }
    }
    return energy;
  }

  double rechargeAll() => recharge(getCurrentMaxEnergy(raw: true) - getCurrentEnergy(raw: true));

  double get hullStrength => shipClass.maxMass;

  bool takeDamage(double dam) {
    Shield? shield = getCurrentShield; if (shield != null) {
      dam -= shield.burn(dam,partial: true);
    }
    hullDamage += dam;
    return hullDamage >= hullStrength;
  }

  String damageReport() {
    return "${hullStrength - hullDamage} hull remaining";
  }

  Weapon? get primaryWeapon => availableWeapons.sorted((w1,w2) => w1.baseCost - w2.baseCost).firstOrNull;

  FireResult? fireWeapons(ImpulseCell target, Random rnd, {Ship? ship}) {
    final l = loc;
    if (l is ImpulseLocation && (ship == null || ship.loc.sameLevel(loc))) {
      double dmg = 0;
      int? minCool;
      bool ammoWarn = false;
      for (final weapon in readyWeapons) {
        bool ammoOK = true; int? clips;
        if (weapon.ammo != null) {
          ammoOK = ammoMap.containsKey(weapon.ammo) && ammoMap[weapon.ammo]! > 0;
          if (ammoOK) {
            final prevAmmo = ammoMap[weapon.ammo]!;
            final newAmmo = max(prevAmmo - weapon.clipRate,0);
            ammoMap[weapon.ammo!] = newAmmo;
            clips = prevAmmo - newAmmo;
          } else {
            ammoWarn = true;
          }
        }
        if (ammoOK) {
          dmg += weapon.fire(l.cell.coord.distance(target.coord), rnd, targetShip: ship, clips: clips);
          if (minCool == null || minCool > weapon.cooldown) minCool = weapon.cooldown;
        }
      }
      return FireResult(dmg,minCool,ammoWarn);
    }
    return null;
  }

  int get turnsUntilWeaponReady {
    int t = 999;
    for (final w in getInstalledSystems([ShipSystemType.weapon])) {
      if (w is Weapon && w.active) {
        if (w.cooldown == 0) return 0;
        if (w.cooldown < t) t = w.cooldown;
      }
    }
    return t;
  }

  bool addAmmo(Ammo ammo, int n) {
    if (okMass(ammo.mass * n)) return false;
    ammoMap[ammo] = ammoMap.containsKey(ammo) ? ammoMap[ammo]! + n : n;
    return true;
  }

  double get currentMass {
    double m = 0;
    for (final ammo in ammoMap.keys) {
      m += ammoMap[ammo]! * ammo.mass;
    }
    m += scrapHeap.fold<double>(0.0, (sum, i) => sum + i.mass);
    return (getAllInstalledSystems.fold<double>(0.0, (sum, s) => sum + s.mass)) + m;
  }

  double get availableMass => shipClass.maxMass - currentMass;
  bool okMass(double m) => availableMass < m;

  //true if intercepted a ship in a sector
  bool move(GridCell destination, {bool toSystem = false, ImpulseLevel? impLevel }) {
    loc.level.removeShip(this);

    ShipLocation l = loc; loc = switch(l) {
      SystemLocation() => impLevel != null ? ImpulseLocation(l,impLevel,destination) : SystemLocation(l.level,destination),
      ImpulseLocation() => toSystem? l.systemLoc : ImpulseLocation(l.systemLoc,l.level,destination),
    };

    loc.level.addShip(this, destination);

    return (loc is SystemLocation && pilot is Player && loc.level.shipsAt(destination).length > 1);
  }

  void tick(Random rnd) {
    for (final rss in getInstalledSystems([ShipSystemType.power,ShipSystemType.shield])) {
      if (rss is RechargableShipSystem && rss.active && rss.currentEnergy < rss.currentMaxEnergy) {
        double recharge;
        if (rss.currentEnergy < 1) {
          recharge = (rnd.nextInt(rss.avgRecoveryTime) == 0) ? 1 : 0;
        } else {
          recharge = rss.currentMaxEnergy * rss.rechargeRate * (1-rss.damage); //print("Recharging: ${rss.name}: $recharge");
        }
        rss.recharge(recharge);
      }
    }
    //double totalBurn = 0;
    for (final s in installedSystems) {
      if (s.system != null && s.system!.active) {
        double e = s.system!.powerDraw; //print("Burning: $e");
        burnEnergy(e); //totalBurn += e;
      }
    } //print("$name: Net energy per tick: ${recharge - totalBurn}");

    for (final w in getInstalledSystems([ShipSystemType.weapon])) {
      if (w is Weapon && w.cooldown > 0) w.cooldown--;
    }
  }

  List<TextBlock> status({bool tactical = false}) {
    List<TextBlock> blocks = [];
    blocks.add(TextBlock(name,Colors.green,true));
    blocks.add(TextBlock("Hull: ${hullRemaining.toStringAsFixed(2)} ",Colors.green,false));
    blocks.add(TextBlock("%: ${currentHullPercentage.toStringAsFixed(2)}",Colors.blue,true));
    blocks.add(TextBlock("Shields: ${currentShieldStrength.toStringAsFixed(2)}, ",Colors.green,false));
    blocks.add(TextBlock("%: ${currentShieldPercentage.toStringAsFixed(2)}",Colors.blue,true));
    blocks.add(TextBlock("Energy: ${getCurrentEnergy().toStringAsFixed(2)}, ",Colors.green,false));
    blocks.add(TextBlock("%: ${currentEnergyPercentage.round().toStringAsFixed(2)}",Colors.blue,true));
    for (final system in installedSystems) { ShipSystem? s = system.system;
      if (s != null) {
        bool cooldown = s is Weapon && s.cooldown > 0;
        blocks.add(TextBlock("${s.name} ${s.active ? '+' : '-'}",cooldown ? Colors.red : Colors.white,true));
      }
    }
    if (!tactical) {
      blocks.add(TextBlock("Remaining capacity: ${availableMass.toStringAsFixed(2)}", Colors.grey, true));
      blocks.add(TextBlock("Total scrap value: ${scrapVal.toStringAsFixed(2)}", Colors.grey, true));
    }
    blocks.add(const TextBlock("",Colors.black,true));
    if (targetCoord != null) blocks.add(TextBlock("Scanning Coord: $targetCoord", Colors.orangeAccent, true));
    if (!tactical && (targetShip != null && targetShip!.npc)) {
      blocks.add(const TextBlock("Scanning Ship: ", Colors.orangeAccent, true));
      blocks.addAll(targetShip!.status(tactical: true));
    }

    return blocks;
  }

  @override
  String toString() {
    return name;
  }

}
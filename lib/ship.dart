import 'dart:math';
import 'package:space_fugue/engines.dart';
import 'package:space_fugue/fugue_model.dart';
import 'package:space_fugue/pilot.dart';
import 'package:space_fugue/player.dart';
import 'package:space_fugue/power.dart';
import 'package:space_fugue/shields.dart';
import 'package:space_fugue/ship_system.dart';
import 'package:space_fugue/weapons.dart';
import 'impulse.dart';
import 'item.dart';
import 'location.dart';
import 'package:flutter/material.dart';

class HullResistance {
  final DamageType dmgType;
  final double resistance;
  const HullResistance(this.dmgType,this.resistance);
}

enum HullType {
  basic([],1),
  ablative([HullResistance(DamageType.kinetic,.5)],2),
  refractive([HullResistance(DamageType.light,.33)],2.5),
  crystalline([
    HullResistance(DamageType.kinetic,.66),
    HullResistance(DamageType.plasma,.25),
  ],5),
  hypercarbon([
    HullResistance(DamageType.fire,.66),
    HullResistance(DamageType.plasma,.5),
    HullResistance(DamageType.sonic,.5),
  ],6.6);
  final List<HullResistance> resistances;
  final double baseRepairCost; //in kilos
  const HullType(this.resistances,this.baseRepairCost);
}

enum ShipClass {
  mentok("Mentok",ShipType.scout,
      [ShipClassSlot(SystemSlot(SystemSlotType.generic,1),8)],
      100
  ),
  galaxy("Galaxy",ShipType.flagship,
      [
        ShipClassSlot(SystemSlot(SystemSlotType.bauchmann,4),4),
        ShipClassSlot(SystemSlot(SystemSlotType.sinclair,2),1),
      ],
      1000
  );
  final String name;
  final ShipType type;
  final List<ShipClassSlot> slots;
  final double maxMass;
  const ShipClass(this.name,this.type,this.slots,this.maxMass);
}

enum ShipType { //TODO: color codes
  scout,skiff,cruiser,destroyer,interceptor,flagship,unknown
}

class InstalledSystem {
  SystemSlot slot;
  ShipSystem? system;
  InstalledSystem(this.slot,this.system);
}

class Ship {
  ShipClass shipClass;
  String name;
  Pilot? pilot;
  Pilot owner;
  List<InstalledSystem> installedSystems = [];
  double hullDamage = 0;
  ShipLocation loc;
  int impulseMapSize = 8;
  Set<Item> inventory = {};
  bool get npc => pilot is! Player;

  Ship(this.name, this.owner, {
    required this.shipClass,
    required this.loc,
    PowerGenerator? generator,
    List<Weapon>? weapons,
    Shield? shield,
    ImpulseEngine? impEngine,
    SublightEngine? subEngine,
    HyperspaceEngine? hyperEngine,
    //TODO: more engines
    bool vacant = false}) {

    if (!vacant) pilot = owner;
    for (final classSlot in shipClass.slots) {
      for (int i=0;i<classSlot.num;i++) {
        installedSystems.add(InstalledSystem(classSlot.slot,null));
      }
    }
    generator ??= stockPP(StockPower.basicNuclear);
    hyperEngine ??= stockHyperspaceEngines[StockHyperspaceEngine.basicFed]!;
    subEngine ??= stockSublightEngines[StockSublightEngine.basicFed]!;
    impEngine ??= stockImpulseEngines[StockImpulseEngine.basicFed]!;
    shield ??= stockShields[StockShield.basicEnergon]!;
    weapons ??= [stockWeapons[StockWeapon.basicLaser]!];


    inventory.add(generator);
    installSystem(generator);
    hyperEngine.active = false;
    inventory.add(hyperEngine);
    installSystem(hyperEngine);
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
    loc.level.map.addShip(this,loc.cell);
  }

  Iterable<ShipSystem> getInstalledSystems(ShipSystemType type) {
    return installedSystems.where((s) => s.system?.type == type).map((i) => i.system!);
  }

  bool installSystem(ShipSystem s) {
    final availableSlots = installedSystems.where((i) => i.system == null && i.slot.supports(s));
    if (availableSlots.isNotEmpty) {
      availableSlots.first.system = s;
      return true;
    }
    return false;
  }

  double get hullRemaining  => (hullStrength-hullDamage);

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
    for (final shield in getInstalledSystems(ShipSystemType.shield)) {
      if (shield is Shield && shield.active) {
        e = shield.currentMaxEnergy; if (shield.currentEnergy > 0) return e;
      }
    }
    return e;
  }

  double get currentShieldStrength {
    for (final shield in getInstalledSystems(ShipSystemType.shield)) {
      if (shield is Shield && shield.active) {
        if (shield.currentEnergy > 0) return shield.currentEnergy;
      }
    }
    return 0;
  }

  bool burnEnergy(double e) {
    for (final gen in getInstalledSystems(ShipSystemType.power)) {
      if (gen is PowerGenerator && gen.active && gen.burn(e)) {
        return true;
      }
    }
    return false;
  }

  double getCurrentMaxEnergy({bool raw = false}) {
    double e = 0;
    for (final gen in getInstalledSystems(ShipSystemType.power)) {
      if (gen is PowerGenerator && gen.active) {
        e += (raw ? gen.rawMaxEnergy : gen.currentMaxEnergy);
      }
    }
    return e;
  }

  double getCurrentEnergy({bool raw = false}) {
    double e = 0;
    for (final gen in getInstalledSystems(ShipSystemType.power)) {
      if (gen is PowerGenerator && gen.active) {
        e += (raw ? gen.rawEnergy : gen.currentEnergy);
      }
    }
    return e;
  }

  ImpulseEngine? get impEngine => getInstalledSystems(ShipSystemType.engine).whereType<ImpulseEngine>().firstOrNull;
  SublightEngine? get subEngine => getInstalledSystems(ShipSystemType.engine).whereType<SublightEngine>().firstOrNull;
  HyperspaceEngine? get hyperEngine => getInstalledSystems(ShipSystemType.engine).whereType<HyperspaceEngine>().firstOrNull;

  double repairHull(double amount) {
    double prevDam = hullDamage;
    hullDamage = max(hullDamage - amount,0);
    return prevDam - hullDamage;
  }

  //int repairAll() { return; }

  double recharge(double energy) {
    for (final gen in getInstalledSystems(ShipSystemType.power)) {
      if (gen is PowerGenerator && gen.active) {
        energy -= gen.recharge(energy);
      }
    }
    return energy;
  }

  double rechargeAll() => recharge(getCurrentMaxEnergy(raw: true) - getCurrentEnergy(raw: true));

  double get hullStrength => shipClass.maxMass;

  bool takeDamage(int dam) {
    hullDamage += dam;  return hullDamage >= hullStrength;
  }

  String damageReport() {
    return "${hullStrength - hullDamage} hull remaining";
  }

  double? fireWeapon(ImpulseCell target, Random rnd) {
    final l = loc;
    if (l is ImpulseLocation) {
      double dmg = 0;
      for (final weapon in getInstalledSystems(ShipSystemType.weapon)) {
        if (weapon is Weapon && weapon.active) {
          dmg += weapon.fire(l.cell.coord.distance(target.coord), rnd, targetShip: l.level.map.shipMap[target]?.first); //multiple ships at loc?
        }
      }
      return dmg;
    } return null;
  }

  void tick() {
    double recharge = 0;
    for (final pp in getInstalledSystems(ShipSystemType.power)) {
      if (pp is PowerGenerator && pp.active && pp.currentEnergy < pp.currentMaxEnergy) {
        recharge = pp.currentMaxEnergy * pp.rechargeRate * (1-pp.damage); print("Recharging: $recharge");
        pp.recharge(recharge);
      }
    }
    double totalBurn = 0;
    for (final s in installedSystems) {
      if (s.system != null && s.system!.active) {
        double e = s.system!.powerDraw; print("Burning: $e");
        burnEnergy(e);
        totalBurn += e;
      }
    }
    print("$name: Net energy per tick: ${recharge - totalBurn}");
  }

  List<TextBlock> status() {
    List<TextBlock> blocks = [];
    blocks.add(TextBlock(name,Colors.green,true));
    blocks.add(TextBlock("Hull: $hullRemaining ",Colors.green,false));
    blocks.add(TextBlock("%: $currentHullPercentage",Colors.blue,true));
    blocks.add(TextBlock("Shields: $currentShieldStrength, ",Colors.green,false));
    blocks.add(TextBlock("%: $currentShieldPercentage",Colors.blue,true));
    blocks.add(TextBlock("Energy: ${getCurrentEnergy().toStringAsFixed(2)}, ",Colors.green,false));
    blocks.add(TextBlock("%: ${currentEnergyPercentage.round()}",Colors.blue,true));
    for (final s in installedSystems) {
      if (s.system != null) {
        blocks.add(TextBlock("${s.system!.name} ${s.system!.active ? '+' : '-'}",Colors.white,true));
      }
    }
    return blocks;
  }

  @override
  String toString() {
    return name;
  }

}
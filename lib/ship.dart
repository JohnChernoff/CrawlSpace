import 'dart:math';
import 'dart:ui';
import 'package:space_fugue/engines.dart';
import 'package:space_fugue/pilot.dart';
import 'package:space_fugue/player.dart';
import 'package:space_fugue/power.dart';
import 'package:space_fugue/shields.dart';
import 'package:space_fugue/ship_system.dart';
import 'package:space_fugue/weapons.dart';
import 'impulse.dart';
import 'item.dart';
import 'location.dart';

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

enum ShipType {
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
    List<Weapon>? weapons, //stockWeapons[StockWeapon.basicLaser]!,
    Shield? shield, // = stockShields[StockShield.basicEnergon]!,
    ImpulseEngine? impEngine, // = stockImpulseEngines[StockImpulseEngine.basicFed]!,
    //TODO: more engines
    bool vacant = false}) {

    if (!vacant) pilot = owner;
    for (final classSlot in shipClass.slots) {
      for (int i=0;i<classSlot.num;i++) {
        installedSystems.add(InstalledSystem(classSlot.slot,null));
      }
    }
    impEngine ??= stockImpulseEngines[StockImpulseEngine.basicFed]!;
    shield ??= stockShields[StockShield.basicEnergon]!;
    weapons ??= [stockWeapons[StockWeapon.basicLaser]!];
    inventory.add(impEngine);
    installSystem(impEngine);
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

  //double hullPercent() => 1.0 - (damage / hull.value);
  //double energyPercent() => energy / battery.value;

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

  double get currentShieldStrength {
    for (final shield in getInstalledSystems(ShipSystemType.shield)) {
      if (shield is Shield && shield.active) {
        double shieldStrength = shield.strength * shield.damage;
        if (shieldStrength > 0) return shieldStrength;
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
        e +=  (raw ? gen.rawEnergy : gen.currentEnergy);
      }
    }
    return e;
  }

  ImpulseEngine? get impEngine => getInstalledSystems(ShipSystemType.engine).whereType<ImpulseEngine>().firstOrNull;

  String status({int ? currentShields}) {
    return "$name: $hullStrength hull, ${currentShields ?? currentShieldStrength} shields";
  }

  @override
  String toString() {
    return name;
  }

}
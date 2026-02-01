import 'dart:math' as math;
import 'package:space_fugue/galaxy.dart';
import 'package:space_fugue/rng.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/stock_items/stock_weapons.dart';
import 'package:space_fugue/systems/ship_system.dart';

enum DamageType {
  light, plasma, fire, kinetic, sonic, gravitron, neutrino, etherial
}

enum WeaponEgo {
  none, antiFed, hyperFire, shieldBoost, scrambler, detector, tunneller, disruptor, efficient, extended
}

//enum RangeAttenuation {  linear,exponential }

class RangeConfig {
  final int idealRange;
  final int minRange, maxRange;
  final double closeFalloff, farFalloff;

  const RangeConfig({
      required this.idealRange,
      required this.minRange,
      required this.maxRange,
      required this.closeFalloff,
      required this.farFalloff
  });

  double rangeMultiplier(double dist) {
    if (dist < minRange || dist > maxRange) return 0.0;
    if (dist == idealRange) return 1.0;
    if (dist > idealRange) {
      return math.exp(-farFalloff * (dist - idealRange));
    } else {
      return math.exp(-closeFalloff * (idealRange - dist));
    }
  }
}

class CritConfig {
  final double baseChance;      // baseline crit probability
  final double severity;        // how hard crits hit
  final double accuracyScaling; // how much accuracy above 100% matters

  const CritConfig({
    this.baseChance = 0.0,
    this.severity = 1.0,
    this.accuracyScaling = 0.0,
  });
}

class Weapon extends ShipSystem {
  final int dmgDice;
  final int dmgDiceSides;
  final int dmgBase;
  final double dmgMult;
  final DamageType dmgType;
  final WeaponEgo ego;
  final int clipRate; //pounds of ammo per round of fire
  final int energyRate; //units of energy per round of fire
  final int fireRate; //aut to complete one round of fire
  final double baseAccuracy; //base chance to hit
  final RangeConfig dmgRangeConfig;
  final RangeConfig accuracyRangeConfig;
  final CritConfig critConfig;
  final GalaxyLevel level;

  Weapon(super.name,{
    super.type = ShipSystemType.weapon,
    required this.dmgDice,
    required this.dmgDiceSides,
    required this.dmgBase,
    required this.dmgType,
    required this.ego,
    required this.clipRate,
    required this.energyRate,
    required this.fireRate,
    required this.baseAccuracy,
    required this.dmgRangeConfig,
    required this.accuracyRangeConfig,
    this.level = GalaxyLevel.impulse,
    this.dmgMult = 1.0,
    this.critConfig = const CritConfig(),
    required super.baseCost,
    required super.baseRepairCost,
    required super.powerDraw,
    required super.mass,
    super.slot,
    super.rarity,
    super.stability,
    super.repairDifficulty,
  });

  factory Weapon.fromStock(StockWeapon stock) {
    WeaponData data = stockWeapons[stock]!;
    return Weapon(
      data.systemData.name,
      slot: data.systemData.slot,
      mass: data.systemData.mass,
      powerDraw: data.systemData.powerDraw,
      stability: data.systemData.stability,
      baseCost: data.systemData.baseCost,
      baseRepairCost: data.systemData.baseRepairCost,
      repairDifficulty: data.systemData.repairDifficulty,
      rarity: data.systemData.rarity,
      //
      dmgDice: data.dmgDice,
      dmgDiceSides: data.dmgDiceSides,
      dmgBase: data.dmgBase,
      dmgType: data.dmgType,
      ego: data.ego,
      clipRate: data.clipRate,
      energyRate: data.energyRate,
      fireRate: data.fireRate,
      baseAccuracy: data.baseAccuracy,
      dmgRangeConfig: data.dmgRangeConfig,
      accuracyRangeConfig: data.accuracyRangeConfig,
      level: data.level,
      dmgMult: data.dmgMult,
      critConfig: data.critConfig,
    );
  }

  double fire(double dist, math.Random rnd, {Ship? targetShip}) {
    double damage = 0;
    double hitRoll = rnd.nextDouble();
    double effectiveAccuracy = baseAccuracy * accuracyRangeConfig.rangeMultiplier(dist);

    bool hit = hitRoll < effectiveAccuracy;

    if (hit) {
      damage = _calcDamage(dist, rnd);
      double overhit = effectiveAccuracy - hitRoll;
      double critChance = math.min(
        1.0,
        critConfig.baseChance +
            (overhit * critConfig.accuracyScaling),
      );
      if (rnd.nextDouble() < critChance) {
        damage *= critConfig.severity;
      }
    }

    return damage;
  }

  double _calcDamage(double dist, math.Random rnd) {
    double dmg = dmgBase + Rng.rollDice(dmgDice, dmgDiceSides, rnd) * dmgMult;
    print("Gross damage: $dmg");
    //TODO: egos, etc.
    final netDamage = dmg * dmgRangeConfig.rangeMultiplier(dist);
    print("Net damage: $netDamage");
    return netDamage;
  }

}

class WeaponData {
  final ShipSystemData systemData;
  final int dmgDice;
  final int dmgDiceSides;
  final int dmgBase;
  final double dmgMult;
  final DamageType dmgType;
  final WeaponEgo ego;
  final int clipRate; //pounds of ammo per round of fire
  final int energyRate; //units of energy per round of fire
  final int fireRate; //aut to complete one round of fire
  final double baseAccuracy; //base chance to hit
  final RangeConfig dmgRangeConfig;
  final RangeConfig accuracyRangeConfig;
  final CritConfig critConfig;
  final GalaxyLevel level;

  const WeaponData({
    required this.systemData,
    required this.dmgDice,
    required this.dmgDiceSides,
    required this.dmgBase,
    required this.dmgType,
    required this.ego,
    required this.clipRate,
    required this.energyRate,
    required this.fireRate,
    required this.baseAccuracy,
    required this.dmgRangeConfig,
    required this.accuracyRangeConfig,
    this.level = GalaxyLevel.impulse,
    this.dmgMult = 1.0,
    this.critConfig = const CritConfig(),
  });
}
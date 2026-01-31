import 'dart:math' as math;
import 'package:space_fugue/galaxy.dart';
import 'package:space_fugue/rng.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/ship_system.dart';

enum DamageType {
  light, plasma, fire, kinetic, sonic, gravitron, neutrino, etherial
}

enum WeaponEgo {
  none, antiFed, hyperFire, shieldBoost, scrambler, detector, tunneller, disruptor, efficient, extended
}

enum StockWeapon { basicLaser }
Map<StockWeapon,Weapon> stockWeapons = {
  StockWeapon.basicLaser : Weapon( "Basic Laser",
    baseCost: 100,
    baseRepairCost: 1.5,
    powerDraw: .25,
    dmgDice: 1,
    dmgDiceSides: 6,
    dmgBase: 1,
    dmgType: DamageType.light,
    ego: WeaponEgo.none,
    clipRate: 0,
    energyRate: 20,
    fireRate: 10,
    baseAccuracy: .8,
    dmgRangeConfig: const RangeConfig(idealRange: 1, minRange: 0, maxRange: 4, closeAttenuation: .1, farAttenuation: .7),
    accuracyRangeConfig: const RangeConfig(idealRange: 1, minRange: 0, maxRange: 4, closeAttenuation: .1, farAttenuation: .33),
    mass: 10,
  )};

//enum RangeAttenuation {  linear,exponential }

class RangeConfig {
  final int idealRange;
  final int minRange, maxRange;
  final double closeAttenuation, farAttenuation;

  const RangeConfig({
      required this.idealRange,
      required this.minRange,
      required this.maxRange,
      required this.closeAttenuation,
      required this.farAttenuation
  });

  double rangeMultiplier(double dist) {
    if (dist < minRange || dist > maxRange) return 0.0;
    if (dist == idealRange) return 1.0;
    if (dist > idealRange) {
      return math.exp(-farAttenuation * (dist - idealRange));
    } else {
      return math.exp(-closeAttenuation * (idealRange - dist));
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
    super.rarity,
    super.stability,
    super.repairDifficulty,
  });

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
            overhit * critConfig.accuracyScaling,
      );
      if (rnd.nextDouble() < critChance) {
        damage *= critConfig.severity;
      }
    }

    return damage;
  }

  double _calcDamage(double dist, math.Random rnd) {
    double dmg = dmgBase + Rng.rollDice(dmgDice, dmgDiceSides, rnd) * dmgMult;
    //TODO: egos, etc.
    return dmg * dmgRangeConfig.rangeMultiplier(dist);
  }

}
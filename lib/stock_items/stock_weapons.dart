import 'package:space_fugue/systems/weapons.dart';

import '../systems/ship_system.dart';

enum StockWeapon { fedLaser1,fedLaser2,fedLaser3, plasmaRay, gravRifle, vibraSlap, neuRad}

final Map<StockWeapon, WeaponData> stockWeapons = {
  StockWeapon.fedLaser1: const WeaponData(
    systemData: ShipSystemData("Fed Laser Mk 1",
        mass: 10, baseCost: 100, baseRepairCost: 1.5, powerDraw: .5),
    dmgDice: 1,
    dmgDiceSides: 60,
    dmgBase: 1,
    dmgType: DamageType.light,
    energyRate: 20,
    fireRate: 10,
    baseAccuracy: .8,
    dmgRangeConfig: RangeConfig(idealRange: 1.5, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .5),
    accuracyRangeConfig: RangeConfig(idealRange: 1.5, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .33),
  ),

  StockWeapon.fedLaser2: const WeaponData(
    systemData: ShipSystemData("Fed Laser Mk 2",
        mass: 10, baseCost: 250, baseRepairCost: 1.5, powerDraw: .5),
    dmgDice: 4,
    dmgDiceSides: 20,
    dmgBase: 8,
    dmgType: DamageType.light,
    energyRate: 20,
    fireRate: 8,
    baseAccuracy: .8,
    dmgRangeConfig: RangeConfig(idealRange: 1.5, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .33),
    accuracyRangeConfig: RangeConfig(idealRange: 1.5, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .25),
  ),

  StockWeapon.fedLaser3: const WeaponData(
    systemData: ShipSystemData("Fed Laser Mk 3",
        mass: 10, baseCost: 500, baseRepairCost: 1.5, powerDraw: .5),
    dmgDice: 5,
    dmgDiceSides: 25,
    dmgBase: 12,
    dmgType: DamageType.light,
    energyRate: 20,
    fireRate: 8,
    baseAccuracy: .9,
    dmgRangeConfig: RangeConfig(idealRange: 1.5, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .33),
    accuracyRangeConfig: RangeConfig(idealRange: 1.5, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .2),
  ),

  StockWeapon.plasmaRay: const WeaponData(
    systemData: ShipSystemData("Plasma Cannon",
        mass: 10, baseCost: 1000, baseRepairCost: 1.5, powerDraw: .5),
    dmgDice: 4,
    dmgDiceSides: 60,
    dmgBase: 16,
    dmgType: DamageType.plasma,
    energyRate: 36,
    fireRate: 16,
    baseAccuracy: .8,
    dmgRangeConfig: RangeConfig(idealRange: 2, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .2),
    accuracyRangeConfig: RangeConfig(idealRange: 4, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .1),
  ),

  StockWeapon.gravRifle: const WeaponData(
    systemData: ShipSystemData("Gravimetric Pulse Rifle",
        mass: 10, baseCost: 1000, baseRepairCost: 1.5, powerDraw: .6, rarity: .4,
        slot: SystemSlot(SystemSlotType.bauchmann,1)),
    dmgDice: 4,
    dmgDiceSides: 24,
    dmgBase: 16,
    dmgType: DamageType.gravitron,
    energyRate: 12,
    fireRate: 4,
    baseAccuracy: .8,
    dmgRangeConfig: RangeConfig(idealRange: 2, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .2),
    accuracyRangeConfig: RangeConfig(idealRange: 4, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .1),
  ),

  StockWeapon.vibraSlap: const WeaponData(
    systemData: ShipSystemData("Cosmosonic Emitter",
        mass: 10, baseCost: 1000, baseRepairCost: 1.5, powerDraw: .6, rarity: .4,
        slot: SystemSlot(SystemSlotType.sinclair,1)),
    dmgDice: 8,
    dmgDiceSides: 24,
    dmgBase: 32,
    dmgType: DamageType.sonic,
    energyRate: 48,
    fireRate: 24,
    baseAccuracy: .8,
    dmgRangeConfig: RangeConfig(idealRange: 2, minRange: 2, maxRange: 12, closeFalloff: .01, farFalloff: .05),
    accuracyRangeConfig: RangeConfig(idealRange: 4, minRange: 2, maxRange: 12, closeFalloff: .01, farFalloff: .05),
  ),

  StockWeapon.neuRad: const WeaponData(
    systemData: ShipSystemData("Neutronic Radiator",
        mass: 10, baseCost: 1000, baseRepairCost: 1.5, powerDraw: .6, rarity: .4,
        slot: SystemSlot(SystemSlotType.sinclair,1)),
    dmgDice: 8,
    dmgDiceSides: 32,
    dmgBase: 24,
    dmgType: DamageType.neutrino,
    energyRate: 60,
    fireRate: 32,
    baseAccuracy: .8,
    dmgRangeConfig: RangeConfig(idealRange: 2, minRange: 1, maxRange: 8, closeFalloff: .1, farFalloff: .1),
    accuracyRangeConfig: RangeConfig(idealRange: 4, minRange: 1, maxRange: 8, closeFalloff: .1, farFalloff: .1),
  ),


};

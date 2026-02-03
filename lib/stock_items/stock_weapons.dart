import 'package:space_fugue/systems/weapons.dart';

import '../systems/ship_system.dart';

enum StockWeapon { fedLaser1,fedLaser2,fedLaser3, plasmaRay, plasmaCannon, fedTorp1 }

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
    energyRate: 20,
    fireRate: 12,
    baseAccuracy: .8,
    dmgRangeConfig: RangeConfig(idealRange: 2, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .2),
    accuracyRangeConfig: RangeConfig(idealRange: 4, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .1),
  ),

  StockWeapon.plasmaCannon: const WeaponData(
    systemData: ShipSystemData("Plasma Cannon",
        mass: 10, baseCost: 7500, baseRepairCost: 1.5, powerDraw: .5, rarity: .5,
        slot: SystemSlot(SystemSlotType.bauchmann,1)),
    dmgDice: 0, dmgDiceSides: 0, dmgBase: 0,
    dmgType: DamageType.plasma,
    energyRate: 20,
    fireRate: 12,
    baseAccuracy: .8,
    clipRate: 1,
    dmgRangeConfig: RangeConfig(idealRange: 2, minRange: 0, maxRange: 12, closeFalloff: .1, farFalloff: .1),
    accuracyRangeConfig: RangeConfig(idealRange: 4, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .1),
  ),

  StockWeapon.fedTorp1: const WeaponData(
    systemData: ShipSystemData("Fed Torp Mk 1",
        mass: 10, baseCost: 10000, baseRepairCost: 1.5, powerDraw: .5, rarity: .5,
        slot: SystemSlot(SystemSlotType.bauchmann,1)),
    dmgDice: 0, dmgDiceSides: 0, dmgBase: 0,
    dmgType: DamageType.kinetic,
    dmgMult: 2,
    energyRate: 20,
    fireRate: 10,
    baseAccuracy: .8,
    clipRate: 1,
    dmgRangeConfig: RangeConfig(idealRange: 1, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .5),
    accuracyRangeConfig: RangeConfig(idealRange: 1, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .33),
    ammoType: AmmoType.torpedo,
  ),

};



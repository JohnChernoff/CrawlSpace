import 'package:space_fugue/systems/weapons.dart';

import '../systems/ship_system.dart';

enum StockWeapon { basicLaser, basicTorp }

final Map<StockWeapon, WeaponData> stockWeapons = {
  StockWeapon.basicLaser: const WeaponData(
    systemData: ShipSystemData("Basic Laser",
        mass: 10, baseCost: 100, baseRepairCost: 1.5, powerDraw: .5),
    dmgDice: 1,
    dmgDiceSides: 60,
    dmgBase: 1,
    dmgType: DamageType.light,
    energyRate: 20,
    fireRate: 10,
    baseAccuracy: .8,
    dmgRangeConfig: RangeConfig(idealRange: 1, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .5),
    accuracyRangeConfig: RangeConfig(idealRange: 1, minRange: 0, maxRange: 8, closeFalloff: .1, farFalloff: .33),
  ),

  StockWeapon.basicTorp: const WeaponData(
    systemData: ShipSystemData("Basic Laser",
        mass: 10, baseCost: 100, baseRepairCost: 1.5, powerDraw: .5),
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



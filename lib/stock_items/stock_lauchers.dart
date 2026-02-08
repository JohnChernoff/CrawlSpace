import '../systems/ship_system.dart';
import '../systems/weapons.dart';

enum StockRangedWeapon {plasmaCannon, fedTorp1}

final Map<StockRangedWeapon, WeaponData> stockLaunchers = {
  StockRangedWeapon.plasmaCannon: const WeaponData(
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

  StockRangedWeapon.fedTorp1: const WeaponData(
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


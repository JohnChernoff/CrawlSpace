import 'package:space_fugue/power.dart';
import 'package:space_fugue/ship_system.dart';

enum StockShield { basicEnergon }
Map<StockShield,Shield> stockShields = {
  StockShield.basicEnergon : Shield("Basic Energon Shield",
    shieldType: ShieldType.energon,
    maxEnergy: 200,
    stability: .5,
    repairDifficulty: .5,
    rechargeRate: .2,
    baseCost: 500,
    baseRepairCost: 2.5,
    rarity: .05,
    powerDraw: 2.5,
    mass: 50
  )
};

enum ShieldType {
  fusion, fission, energon, gravimetric, nullSpace, darkMatter
}

enum ShieldEgo {
  none, endurance, recharging, spike, reflector, absorption
}

class Shield extends RechargableShipSystem {
  final ShieldType shieldType;
  final ShieldEgo ego;

  Shield(super.name,{
    super.type = ShipSystemType.shield,
    this.ego = ShieldEgo.none,
    required this.shieldType,
    required super.maxEnergy,
    required super.rechargeRate,
    required super.baseCost,
    required super.baseRepairCost,
    required super.powerDraw,
    required super.mass,
    super.rarity,
    super.stability,
    super.repairDifficulty,
  });


}
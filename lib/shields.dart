import 'package:space_fugue/ship_system.dart';

enum StockShield { basicEnergon }
Map<StockShield,Shield> stockShields = {
  StockShield.basicEnergon : Shield("Basic Energon Shield", ShieldType.energon,
    strength: 200,
    stability: .5,
    repairDifficulty: .5,
    rechargeRate: .2,
    baseCost: 500,
    baseRepairCost: 2.5,
    rarity: .05,
    powerDraw: .25,
  )
};

enum ShieldType {
  fusion, fission, energon, gravimetric, nullSpace, darkMatter
}

enum ShieldEgo {
  none, endurance, recharging, spike, reflector, absorption
}

class Shield extends ShipSystem {
  int strength;
  double rechargeRate;
  final ShieldType type;
  final ShieldEgo ego;

  Shield(super.name,this.type,{this.ego = ShieldEgo.none,
    required this.strength,
    required this.rechargeRate,
    required super.baseCost,
    required super.baseRepairCost,
    required super.rarity,
    required super.powerDraw, required super.stability, required super.repairDifficulty,

  });
}
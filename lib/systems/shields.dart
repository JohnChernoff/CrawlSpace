import 'package:space_fugue/stock_items/stock_shields.dart';
import 'package:space_fugue/systems/power.dart';
import 'package:space_fugue/systems/ship_system.dart';

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
    super.slot,
    super.rarity,
    super.stability,
    super.repairDifficulty,
  });

  factory Shield.fromStock(StockShield stock) {
    ShieldData data = stockShields[stock]!;
    return Shield(
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
      shieldType: data.shieldType,
      maxEnergy: data.maxEnergy,
      rechargeRate: data.rechargeRate
    );
  }
}

class ShieldData {
  final ShipSystemData systemData;
  final double maxEnergy;
  final double rechargeRate;
  final ShieldType shieldType;
  final ShieldEgo ego;

  const ShieldData({
    required this.systemData,
    required this.maxEnergy,
    required this.rechargeRate,
    required this.shieldType,
    this.ego = ShieldEgo.none,
  });
}
import 'package:space_fugue/systems/shields.dart';
import '../systems/ship_system.dart';

enum StockShield { basicEnergon }

final Map<StockShield, ShieldData> stockShields = {
  StockShield.basicEnergon: const ShieldData(
    systemData: ShipSystemData("Basic Energon Shield",
        mass: 50, baseCost: 500, baseRepairCost: 2.5, powerDraw: 2.5),
      shieldType: ShieldType.energon,
      maxEnergy: 200,
      rechargeRate: .001,
      avgRecoveryTime: 100,
  ),
};


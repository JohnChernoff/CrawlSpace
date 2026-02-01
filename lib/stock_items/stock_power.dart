import 'package:space_fugue/systems/power.dart';

import '../systems/ship_system.dart';

enum StockPower { basicNuclear }

final Map<StockPower, PowerData> stockPPs = {
  StockPower.basicNuclear: const PowerData(
    systemData: ShipSystemData("Mark I Fed Power Plant",
        mass: 75, baseCost: 250, baseRepairCost: 1, powerDraw: 0),
    powerType: PowerType.nuclear,
    maxEnergy: 500,
    rechargeRate: 0.02,
    avgRecoveryTime: 10,
  ),
};

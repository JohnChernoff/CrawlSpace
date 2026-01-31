import 'package:space_fugue/systems/power.dart';

enum StockPower { basicNuclear }
class StockPowerData {
  final String name;
  final PowerType powerType;
  final double maxEnergy;
  final double rechargeRate;
  final int baseCost;
  final double baseRepairCost;
  final double mass;
  final double powerDraw;

  const StockPowerData({
    required this.name,
    required this.powerType,
    required this.maxEnergy,
    required this.rechargeRate,
    required this.baseCost,
    required this.baseRepairCost,
    required this.mass,
    required this.powerDraw,
  });
}

final Map<StockPower, StockPowerData> stockPPs = {
  StockPower.basicNuclear: const StockPowerData(
    name: "Fed Mk 1 Power Plant",
    powerType: PowerType.nuclear,
    maxEnergy: 500,
    rechargeRate: 0.01,
    baseCost: 250,
    baseRepairCost: 1,
    mass: 75,
    powerDraw: 0,
  ),
};

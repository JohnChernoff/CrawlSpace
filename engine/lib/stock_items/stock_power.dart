import 'stock_pile.dart';
import '../systems/power.dart';
import '../systems/ship_system.dart';

final Map<StockSystem, PowerData> stockPPs = {
  StockSystem.basicNuclear: PowerData(
    systemData: ShipSystemData("Mark I Fed Power Plant",
        techLvl: StockSystem.basicEnergon.techLvl, rarity: StockSystem.basicEnergon.rarity,
        mass: 75, baseCost: 250, baseRepairCost: 1, powerDraw: 0),
    powerType: PowerType.nuclear,
    maxEnergy: 500,
    rechargeRate: 0.02,
    avgRecoveryTime: 10,
  ),
  StockSystem.zemlinsky: PowerData(
    systemData: ShipSystemData("Zemlinsky Antimatter Power Plant",
        techLvl: StockSystem.zemlinsky.techLvl, rarity: StockSystem.zemlinsky.rarity,
        mass: 75, baseCost: 500, baseRepairCost: 1, powerDraw: 0),
    powerType: PowerType.antimatter,
    maxEnergy: 750,
    rechargeRate: 0.02,
    avgRecoveryTime: 10,
  ),
  StockSystem.aojginx: PowerData(
    systemData: ShipSystemData("Aogjinx Dark Matter Power Plant",
        techLvl: StockSystem.aojginx.techLvl, rarity: StockSystem.aojginx.rarity,
        mass: 75, baseCost: 1000, baseRepairCost: 1, powerDraw: 0),
    powerType: PowerType.dark,
    maxEnergy: 900,
    rechargeRate: 0.03,
    avgRecoveryTime: 10,
  ),
  StockSystem.bellauxfz: PowerData(
    systemData: ShipSystemData("Bellauxfz Quantum Power Plant",
        techLvl: StockSystem.bellauxfz.techLvl, rarity: StockSystem.bellauxfz.rarity,
        mass: 75, baseCost: 2500, baseRepairCost: 1, powerDraw: 0),
    powerType: PowerType.quantum,
    maxEnergy: 1500,
    rechargeRate: 0.04,
    avgRecoveryTime: 10,
  ),
  StockSystem.gjellorny: PowerData(
    systemData: ShipSystemData("Gjellorny Multiplanar Power Plant",
        techLvl: StockSystem.gjellorny.techLvl, rarity: StockSystem.gjellorny.rarity,
        mass: 75, baseCost: 5000, baseRepairCost: 1, powerDraw: 0),
    powerType: PowerType.astral,
    maxEnergy: 2000,
    rechargeRate: 0.05,
    avgRecoveryTime: 10,
  ),
};

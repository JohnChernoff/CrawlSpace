import 'stock_pile.dart';
import '../systems/shields.dart';
import '../systems/ship_system.dart';

final Map<StockSystem, ShieldData> stockShields = {
  StockSystem.basicEnergon: ShieldData(
    systemData: ShipSystemData("Basic Energon Shield",
        techLvl: StockSystem.basicEnergon.techLvl, rarity: StockSystem.basicEnergon.rarity,
        mass: 50, baseCost: 500, baseRepairCost: 2.5, powerDraw: 2.5),
      shieldType: ShieldType.energon,
      maxEnergy: 200,
      rechargeRate: .001,
      avgRecoveryTime: 100,
  ),
  StockSystem.movEnergon: ShieldData(
    systemData: ShipSystemData("Movelian Energon Shield",
        techLvl: StockSystem.movEnergon.techLvl, rarity: StockSystem.movEnergon.rarity,
        mass: 50, baseCost: 1000, baseRepairCost: 2.5, powerDraw: 3),
    shieldType: ShieldType.energon,
    maxEnergy: 300,
    rechargeRate: .002,
    avgRecoveryTime: 100,
  ),
  StockSystem.cassat: ShieldData(
    systemData: ShipSystemData("Cassat Fission Shield",
        techLvl: StockSystem.cassat.techLvl, rarity: StockSystem.cassat.rarity,
        mass: 50, baseCost: 1500, baseRepairCost: 2.5, powerDraw: 4),
    shieldType: ShieldType.fission,
    maxEnergy: 250,
    rechargeRate: .005,
    avgRecoveryTime: 100,
  ),
  StockSystem.remlok: ShieldData(
    systemData: ShipSystemData("Remlock Dark Matter Shield",
        techLvl: StockSystem.remlok.techLvl, rarity: StockSystem.remlok.rarity,
        mass: 50, baseCost: 2500, baseRepairCost: 2.5, powerDraw: 5),
    shieldType: ShieldType.darkMatter,
    maxEnergy: 500,
    rechargeRate: .001,
    avgRecoveryTime: 100,
  ),
  StockSystem.ortegroq: ShieldData(
    systemData: ShipSystemData("Ortegroq Gravimetric Shield",
        techLvl: StockSystem.kevlop.techLvl, rarity: StockSystem.kevlop.rarity,
        mass: 50, baseCost: 7500, baseRepairCost: 2.5, powerDraw: 8),
    shieldType: ShieldType.gravimetric,
    maxEnergy: 600,
    rechargeRate: .001,
    avgRecoveryTime: 100,
  ),
  StockSystem.kevlop: ShieldData(
    systemData: ShipSystemData("Kevlok Fusion Shield",
        techLvl: StockSystem.kevlop.techLvl, rarity: StockSystem.kevlop.rarity,
        mass: 50, baseCost: 7500, baseRepairCost: 2.5, powerDraw: 12),
    shieldType: ShieldType.fusion,
    maxEnergy: 780,
    rechargeRate: .001,
    avgRecoveryTime: 100,
  ),
};


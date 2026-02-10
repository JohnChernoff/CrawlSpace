import '../grid.dart';
import '../systems/engines.dart';
import '../systems/ship_system.dart';
import 'stock_pile.dart';

final Map<StockSystem, EngineData> stockEngines = {
  StockSystem.basicFedImpulse: EngineData(
      systemData: ShipSystemData("Mark I Fed Impulse Engine",
      techLvl: StockSystem.basicFedImpulse.techLvl, rarity: StockSystem.basicFedImpulse.rarity,
      mass: 80, baseCost: 300, baseRepairCost: 2, powerDraw: 5),
    domain: Domain.impulse,
    engineType: EngineType.fedMark1,
    efficiency: .5,
    baseAutPerUnitTraversal: 10,
  ),
  StockSystem.basicFedSublight: EngineData(
    systemData: ShipSystemData("Mark I Fed Sublight Engine",
        techLvl: StockSystem.basicFedSublight.techLvl, rarity: StockSystem.basicFedSublight.rarity,
        mass: 80, baseCost: 300, baseRepairCost: 2, powerDraw: 3.3),
    domain: Domain.system,
    engineType: EngineType.fedMark1,
    efficiency: .5,
    baseAutPerUnitTraversal: 10,
  ),
  StockSystem.basicFedHyperdrive: EngineData(
    systemData: ShipSystemData("Mark I Fed Hyperdrive Engine",
        techLvl: StockSystem.basicFedHyperdrive.techLvl, rarity: StockSystem.basicFedHyperdrive.rarity,
        mass: 80, baseCost: 300, baseRepairCost: 2, powerDraw: 8),
    domain: Domain.hyperspace,
    engineType: EngineType.fedMark1,
    efficiency: .5,
    baseAutPerUnitTraversal: 10,
  ),
  StockSystem.movSublight1: EngineData(
    systemData: ShipSystemData("Mark I Movelian Hyperdrive Engine",
        techLvl: StockSystem.movSublight1.techLvl, rarity: StockSystem.movSublight1.rarity,
        mass: 80, baseCost: 1000, baseRepairCost: 2, powerDraw: 12),
    domain: Domain.system,
    engineType: EngineType.moevelian,
    efficiency: .7,
    baseAutPerUnitTraversal: 7,
  ),

};
import '../systems/engines.dart';
import '../systems/ship_system.dart';

enum StockEngine { basicFedImpulse,basicFedSublight,basicFedHyperdrive }

final Map<StockEngine, EngineData> stockEngines = {
  StockEngine.basicFedImpulse: const EngineData(
      systemData: ShipSystemData("Mark I Fed Impulse Engine",
      mass: 80, baseCost: 300, baseRepairCost: 2, powerDraw: 5),
    domain: EngineDomain.impulse,
    engineType: EngineType.fedMark1,
    efficiency: .5,
    baseAutPerUnitTraversal: 10,
  ),
  StockEngine.basicFedSublight: const EngineData(
    systemData: ShipSystemData("Mark I Fed Sublight Engine",
        mass: 80, baseCost: 300, baseRepairCost: 2, powerDraw: 3.3),
    domain: EngineDomain.sublight,
    engineType: EngineType.fedMark1,
    efficiency: .5,
    baseAutPerUnitTraversal: 10,
  ),
  StockEngine.basicFedHyperdrive: const EngineData(
    systemData: ShipSystemData("Mark I Fed Hyperdrive Engine",
        mass: 80, baseCost: 300, baseRepairCost: 2, powerDraw: 8),
    domain: EngineDomain.hyperspace,
    engineType: EngineType.fedMark1,
    efficiency: .5,
    baseAutPerUnitTraversal: 10,
  ),

};
import 'package:space_fugue/systems/ship_system.dart';

enum StockImpulseEngine { basicFed }
Map<StockImpulseEngine,ImpulseEngine> stockImpulseEngines = {
  StockImpulseEngine.basicFed : ImpulseEngine("Mark I Fed Impulse Engine",
    engineType: ImpulseEngineType.fedMark1,
    baseAutPerUnitTraversal: 10,
    baseCost: 300,
    efficiency: .5,
    baseRepairCost: 2,
    powerDraw: 2.5,
    mass: 80,
  )};

enum StockSublightEngine { basicFed }
Map<StockSublightEngine,SublightEngine> stockSublightEngines = {
  StockSublightEngine.basicFed : SublightEngine("Mark I Fed Sublight Engine",
    engineType: SublightEngineType.fedMark1,
    baseAutPerUnitTraversal: 10,
    baseCost: 300,
    efficiency: .5,
    baseRepairCost: 2,
    powerDraw: 1,
    mass: 80,
  )};

enum StockHyperspaceEngine { basicFed }
Map<StockHyperspaceEngine,HyperspaceEngine> stockHyperspaceEngines = {
  StockHyperspaceEngine.basicFed : HyperspaceEngine("Mark I Fed Hyperspace Engine",
    engineType: HyperspaceEngineType.fedMark1,
    baseAutPerUnitTraversal: 10,
    baseCost: 300,
    efficiency: .5,
    baseRepairCost: 2,
    powerDraw: 5,
    mass: 80,
  )};

class Engine extends ShipSystem {
  int baseAutPerUnitTraversal; //BAPUT
  double efficiency;

  Engine(super.name, {
    super.type = ShipSystemType.engine,
    required this.baseAutPerUnitTraversal,
    required this.efficiency,
    required super.baseCost,
    required super.baseRepairCost,
    required super.powerDraw,
    super.rarity,
    super.stability,
    super.repairDifficulty,
    required super.mass});
}

enum ImpulseEngineType {
  xaxilian, moevelian, fedMark1, fedMark2, krakkarian
}

enum ImpulseEngineEgo {
  none, nebulizer, ionicDampener, wakeProof, supercharged, afterburner
}

class ImpulseEngine extends Engine {
  ImpulseEngineType engineType;
  ImpulseEngineEgo ego;

  ImpulseEngine(super.name, {
    required this.engineType,
    this.ego = ImpulseEngineEgo.none,
    required super.baseAutPerUnitTraversal,
    required super.efficiency,
    required super.baseCost,
    required super.baseRepairCost,
    required super.powerDraw,
    required super.mass,
    super.rarity,
    super.stability,
    super.repairDifficulty,
  });
}

enum SublightEngineType {
  xaxilian, moevelian, fedMark1, fedMark2, krakkarian
}

enum SublightEngineEgo {
  none, nebulizer, ionicDampener, oortProof, supercharged, afterburner
}

class SublightEngine extends Engine {
  SublightEngineType engineType;
  SublightEngineEgo ego;

  SublightEngine(super.name, {
    required this.engineType,
    this.ego = SublightEngineEgo.none,
    required super.baseAutPerUnitTraversal,
    required super.efficiency,
    required super.baseCost,
    required super.baseRepairCost,
    required super.powerDraw,
    required super.mass,
    super.rarity,
    super.stability,
    super.repairDifficulty,
  });
}

enum HyperspaceEngineType {
  xaxilian, moevelian, fedMark1, fedMark2, krakkarian
}

enum HyperspaceEngineEgo {
  none, nebulizer, ionicDampener, oortProof, supercharged, afterburner
}

class HyperspaceEngine extends Engine {
  HyperspaceEngineType engineType;
  HyperspaceEngineEgo ego;

  HyperspaceEngine(super.name, {
    required this.engineType,
    this.ego = HyperspaceEngineEgo.none,
    required super.baseAutPerUnitTraversal,
    required super.efficiency,
    required super.baseCost,
    required super.baseRepairCost,
    required super.powerDraw,
    required super.mass,
    super.rarity,
    super.stability,
    super.repairDifficulty,
  });
}
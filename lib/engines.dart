import 'package:space_fugue/ship_system.dart';

enum StockImpulseEngine {
  basicFed
}

Map<StockImpulseEngine,ImpulseEngine> stockImpulseEngines = {
  StockImpulseEngine.basicFed : ImpulseEngine("Mark I Fed",
    type: ImpulseEngineType.fedMark1,
    baseAutPerUnitTraversal: 10,
    baseCost: 300,
    efficiency: .5,
    baseRepairCost: 2,
    rarity: .1,
    powerDraw: .5,
    stability: .8,
    repairDifficulty: .1
  )};

class Engine extends ShipSystem {
  int baseAutPerUnitTraversal; //BAPUT
  double efficiency;

  Engine(super.name, {
    required this.baseAutPerUnitTraversal,
    required this.efficiency,
    required super.baseCost,
    required super.baseRepairCost,
    required super.rarity,
    required super.powerDraw,
    required super.stability,
    required super.repairDifficulty});
}

enum ImpulseEngineType {
  xaxilian, moevelian, fedMark1, fedMark2, krakkarian
}

enum ImpulseEngineEgo {
  none, nebulizer, ionicDampener, wakeProof, supercharged, afterburner
}

class ImpulseEngine extends Engine {
  ImpulseEngineType type;
  ImpulseEngineEgo ego;

  ImpulseEngine(super.name, {
    required this.type,
    this.ego = ImpulseEngineEgo.none,
    required super.baseAutPerUnitTraversal,
    required super.efficiency,
    required super.baseCost,
    required super.baseRepairCost,
    required super.rarity,
    required super.powerDraw,
    required super.stability,
    required super.repairDifficulty
  });
}
import 'package:space_fugue/ship_system.dart';

enum StockImpulseEngine { basicFed }
Map<StockImpulseEngine,ImpulseEngine> stockImpulseEngines = {
  StockImpulseEngine.basicFed : ImpulseEngine("Mark I Fed",
    engineType: ImpulseEngineType.fedMark1,
    baseAutPerUnitTraversal: 10,
    baseCost: 300,
    efficiency: .5,
    baseRepairCost: 2,
    powerDraw: .5,
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
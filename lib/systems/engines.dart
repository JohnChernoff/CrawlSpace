import 'package:space_fugue/systems/ship_system.dart';

import '../stock_items/stock_engines.dart';

enum EngineDomain {hyperspace,sublight,impulse}

enum EngineEgo {
  none({}),
  nebulizer({EngineDomain.sublight,EngineDomain.impulse}),
  ionicDampener({EngineDomain.sublight,EngineDomain.impulse}),
  oortProof({EngineDomain.sublight}),
  supercharged({EngineDomain.hyperspace,EngineDomain.sublight,EngineDomain.impulse}),
  afterburner({EngineDomain.impulse});
  final Set<EngineDomain> domains;
  const EngineEgo(this.domains);
}

enum EngineType {
  xaxilian({EngineDomain.hyperspace,EngineDomain.sublight,EngineDomain.impulse}),
  moevelian({EngineDomain.hyperspace,EngineDomain.sublight,EngineDomain.impulse}),
  fedMark1({EngineDomain.hyperspace,EngineDomain.sublight,EngineDomain.impulse}),
  fedMark2({EngineDomain.hyperspace,EngineDomain.sublight,EngineDomain.impulse}),
  krakkarian({EngineDomain.hyperspace,EngineDomain.sublight,EngineDomain.impulse});
  final Set<EngineDomain> domains;
  const EngineType(this.domains);
}

class Engine extends ShipSystem {
  int baseAutPerUnitTraversal; //BAPUT
  double efficiency;
  EngineDomain domain;
  EngineType engineType;
  EngineEgo ego;

  Engine(super.name, {
    super.type = ShipSystemType.engine,
    super.slot,
    super.rarity,
    super.stability,
    super.repairDifficulty,
    required this.domain,
    required this.engineType,
    this.ego = EngineEgo.none,
    required this.baseAutPerUnitTraversal,
    required this.efficiency,
    required super.baseCost,
    required super.baseRepairCost,
    required super.powerDraw,
    required super.mass});

  factory Engine.fromStock(StockEngine stock) {
    EngineData data = stockEngines[stock]!;
    return Engine(
      data.systemData.name,
      slot: data.systemData.slot,
      mass: data.systemData.mass,
      powerDraw: data.systemData.powerDraw,
      stability: data.systemData.stability,
      baseCost: data.systemData.baseCost,
      baseRepairCost: data.systemData.baseRepairCost,
      repairDifficulty: data.systemData.repairDifficulty,
      rarity: data.systemData.rarity,
      //
      domain: data.domain,
      engineType: data.engineType,
      ego: data.ego,
      efficiency: data.efficiency,
      baseAutPerUnitTraversal: data.baseAutPerUnitTraversal,
    );
  }
}

class EngineData {
  final ShipSystemData systemData;
  final int baseAutPerUnitTraversal; //BAPUT
  final double efficiency;
  final EngineDomain domain;
  final EngineType engineType;
  final EngineEgo ego;

  const EngineData({
    required this.systemData,
    required this.baseAutPerUnitTraversal,
    required this.efficiency,
    required this.domain,
    required this.engineType,
    this.ego = EngineEgo.none
  });
}



import 'dart:math';
import 'package:space_fugue/stock_items/stock_power.dart';
import 'package:space_fugue/systems/ship_system.dart';

enum PowerType {
  nuclear,antimatter,quantum,dark,astral
}

enum PowerEgo {
  none,nebular,ionic,gravimetric,stable,efficient
}

class RechargableShipSystem extends ShipSystem {
  final double _maxEnergy;
  double _currentEnergy;
  double rechargeRate; //% per aut

  RechargableShipSystem(super.name, {
    required super.type,
    required double maxEnergy,
    required this.rechargeRate,
    required super.baseCost,
    required super.baseRepairCost,
    required super.mass,
    required super.powerDraw,
    super.rarity,
    super.stability,
    super.repairDifficulty,
  }) : _maxEnergy = maxEnergy, _currentEnergy = maxEnergy;

  double recharge(double amount) {
    double prevEnergy = _currentEnergy; //ignore damage
    double newEnergy = min(_currentEnergy + amount,_maxEnergy);
    _currentEnergy = newEnergy;
    return _currentEnergy - prevEnergy;
  }

  bool burn(double e) {
    if (currentEnergy >= e) {
      _currentEnergy -= e; return true;
    } return false;
  }

  double get rawMaxEnergy => _maxEnergy;
  double get currentMaxEnergy => _maxEnergy * (1-damage);
  double get rawEnergy => _currentEnergy;
  double get currentEnergy => _currentEnergy * (1-damage);
}

class PowerGenerator extends RechargableShipSystem {
  PowerType powerType;
  PowerEgo ego;

  PowerGenerator(super.name, {
    super.type = ShipSystemType.power,
    required super.maxEnergy,
    required this.powerType,
    this.ego = PowerEgo.none,
    required super.rechargeRate,
    required super.baseCost,
    required super.baseRepairCost,
    required super.mass,
    required super.powerDraw,
    super.rarity,
    super.stability,
    super.repairDifficulty,
  });

  factory PowerGenerator.fromStock(StockPower stock) {
    final data = stockPPs[stock]!;
    return PowerGenerator(
      data.name,
      powerType: data.powerType,
      maxEnergy: data.maxEnergy,
      rechargeRate: data.rechargeRate,
      baseCost: data.baseCost,
      baseRepairCost: data.baseRepairCost,
      mass: data.mass,
      powerDraw: data.powerDraw,
    );
  }

}
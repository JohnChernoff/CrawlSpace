import 'dart:math';

import 'package:space_fugue/ship_system.dart';

enum StockPower { basicNuclear }
Map<StockPower,PowerGenerator> stockGenerators = {
  StockPower.basicNuclear : PowerGenerator("Fed Mk 1 Power Plant",
    powerType: PowerType.nuclear,
    maxEnergy: 500,
    rechargeRate: 2.5,
    baseCost: 250,
    baseRepairCost: 1,
    mass: 75,
    powerDraw: 0,
  )
};

enum PowerType {
  nuclear,antimatter,quantum,dark,astral
}

enum PowerEgo {
  none,nebular,ionic,gravimetric,stable,efficient
}

class PowerGenerator extends ShipSystem {
  final double _maxEnergy;
  double _currentEnergy;
  double rechargeRate; //% per turn
  PowerType powerType;
  PowerEgo ego;

  PowerGenerator(super.name, {
    super.type = ShipSystemType.power,
    required this.powerType,
    this.ego = PowerEgo.none,
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
  double get currentMaxEnergy => _maxEnergy * damage;
  double get rawEnergy => _currentEnergy;
  double get currentEnergy => _currentEnergy * damage;

}
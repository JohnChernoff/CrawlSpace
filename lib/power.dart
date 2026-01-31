import 'dart:math';
import 'package:space_fugue/ship_system.dart';

enum StockPowerField {name,powertype,maxEnergy,rechargeRate,baseCost,baseRepairCost,mass,powerDraw}
Map<StockPower,Map<StockPowerField,dynamic>> stockPPs = {
  StockPower.basicNuclear : {
    StockPowerField.name : "Fed Mk 1 Power Plant",
    StockPowerField.powertype : PowerType.nuclear,
    StockPowerField.maxEnergy : 500,
    StockPowerField.rechargeRate : .01,
    StockPowerField.baseCost : 250,
    StockPowerField.baseRepairCost : 1,
    StockPowerField.mass : 75,
    StockPowerField.powerDraw : 0,
  }
};

PowerGenerator stockPP(StockPower stockPower) {
  return PowerGenerator(
      stockPPs[stockPower]![StockPowerField.name],
      powerType: stockPPs[stockPower]![StockPowerField.powertype],
      maxEnergy: stockPPs[stockPower]![StockPowerField.maxEnergy],
      rechargeRate: stockPPs[stockPower]![StockPowerField.rechargeRate],
      baseCost: stockPPs[stockPower]![StockPowerField.baseCost],
      baseRepairCost: stockPPs[stockPower]![StockPowerField.baseRepairCost],
      mass: stockPPs[stockPower]![StockPowerField.mass],
      powerDraw: stockPPs[stockPower]![StockPowerField.powerDraw]);
}

enum StockPower { basicNuclear }

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

}
import 'dart:math';

import 'item.dart';

class ShipSystem extends Item {
  final double baseRepairCost; //credits per 1% repair
  double damage;
  int enhancement;
  final int maxEnhancement;
  final double powerDraw; //per 1 aut of use
  final double stability;
  final double repairDifficulty;
  bool active = false;

  ShipSystem(super.name,{
    required super.baseCost,
    required this.baseRepairCost,
    required super.rarity,
    this.damage = 0,
    this.enhancement = 0,
    this.maxEnhancement = 9,
    required this.powerDraw,
    required this.stability,
    required this.repairDifficulty
  });

  bool enhance({int i = 1}) {
    int e = min(maxEnhancement,enhancement + i);
    if (e > enhancement) {
      enhancement = e; return true;
    }
    return false;
  }

  double repair(double r) {
    double dmg = max(damage - r,0);
    if (dmg < damage) {
      final i = damage - dmg;
      damage = dmg; return i;
    } return 0;
  }

}
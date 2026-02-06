import 'dart:math';

import '../item.dart';

class ShipClassSlot {
  final SystemSlot slot;
  final int num;
  const ShipClassSlot(this.slot,this.num);
}

enum ShipSystemType {
  weapon,shield,engine,quarters,power,powerConverter,sensor,unknown;
}

enum SystemSlotType {
  unknown([],[]),
  generic([],ShipSystemType.values),
  rimbaud([],[ShipSystemType.engine,ShipSystemType.power,ShipSystemType.powerConverter]),
  salazar([],[ShipSystemType.weapon,ShipSystemType.power,ShipSystemType.powerConverter]),
  bauchmann([],[ShipSystemType.weapon,ShipSystemType.shield,ShipSystemType.power,ShipSystemType.powerConverter]),
  nimrod([SystemSlotType.rimbaud],[ShipSystemType.weapon,ShipSystemType.shield]),
  lopez([SystemSlotType.salazar],[ShipSystemType.shield]),
  smythe([SystemSlotType.generic],[ShipSystemType.weapon,ShipSystemType.shield]),
  sinclair([SystemSlotType.bauchmann,SystemSlotType.smythe],ShipSystemType.values);

  final List<SystemSlotType> supportedSlots;
  final List<ShipSystemType> supportedTypes;
  const SystemSlotType(this.supportedSlots, this.supportedTypes);

  SystemSlotType? supports(SystemSlotType type, [Set<SystemSlotType>? visited]) {
    visited ??= {};
    if (visited.contains(this)) return null; // cycle detection
    visited.add(this);
    if (this == type) return this;
    for (final s in supportedSlots) {
      final result = s.supports(type, visited);
      if (result != null) return result;
    }
    return null;
  }
}

class SystemSlot {
  final SystemSlotType type;
  final int generation; //mark
  const SystemSlot(this.type,this.generation);

  bool supports(ShipSystem s, {ignoreGenerations = false}) {
    if (s.slot.type == type) {
      if (ignoreGenerations || (generation >= s.slot.generation)) {
        return type.supportedTypes.contains(s.type);
      }
    }
    else { // Inherited compatibility: generation doesn't matter
      final slot = type.supports(s.slot.type);
      if (slot != null) {
        return slot.supportedTypes.contains(s.type);
      }
    }
    return false;
  }

  @override
  String toString() {
    return "${type.name}, gen: $generation";
  }
}

abstract class ShipSystem extends Item {
  final ShipSystemType type;
  final SystemSlot slot;
  final double mass; //kilos
  final double baseRepairCost; //credits per 1% repair
  double damage; //% damaged
  int enhancement;
  final int maxEnhancement;
  final double powerDraw; //per 1 aut of use
  final double stability;
  final double repairDifficulty;
  bool active = true;

  ShipSystem(super.name,{
    required this.type,
    required super.baseCost,
    required this.baseRepairCost,
    super.rarity = .1,
    this.damage = 0,
    this.enhancement = 0,
    this.maxEnhancement = 9,
    this.repairDifficulty = .5,
    this.stability = .8,
    this.slot = const SystemSlot(SystemSlotType.generic,1),
    required this.mass,
    required this.powerDraw,
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

  @override
  String toString() {
    return "${super.toString()}, slot: $slot";
  }
}

class ShipSystemData {
  final String name;
  final SystemSlot slot;
  final double mass; //kilos
  final double rarity;
  final int baseCost;
  final double baseRepairCost; //credits per 1% repair
  final int enhancement;
  final int maxEnhancement;
  final double powerDraw; //per 1 aut of use
  final double stability;
  final double repairDifficulty;

  const ShipSystemData(this.name,{
    this.slot = const SystemSlot(SystemSlotType.generic, 1),
    required this.mass,
    required this.baseCost,
    required this.baseRepairCost,
    required this.powerDraw,
    this.rarity = .1,
    this.enhancement = 0,
    this.maxEnhancement = 9,
    this.stability = .8,
    this.repairDifficulty = .5,
  });
}
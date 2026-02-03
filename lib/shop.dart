import 'dart:math';

import 'package:space_fugue/rng.dart';
import 'package:space_fugue/stock_items/stock_weapons.dart';
import 'package:space_fugue/systems/weapons.dart';

import 'item.dart';

class ShopOptions {
  int costRepair = 1, costRecharge = 1, costBioHack = 50, costBroadcast = 2000;
}

sealed class Shop {
  String name;
  bool buysScrap;
  List<Item> items = [];

  Shop(this.name,{this.buysScrap = false});
  void generateItems(double techLvl, Random rnd, {int avgQuantity = 12});
}

class WeaponShop extends Shop {
  WeaponShop(super.name, {super.buysScrap = true});

  @override
  void generateItems(double techLvl, Random rnd, {int avgQuantity = 12}) {
    items.clear();
    int quantity = Rng.poissonRandom(avgQuantity as double);

    final availableWeapons = stockWeapons.entries
        .where((e) => e.value.systemData.baseCost <= techLvl * 10000)
        .toList();

    if (availableWeapons.isEmpty) return;

    // Bias toward lower-cost items (more common)
    availableWeapons.sort((a, b) =>
        a.value.systemData.baseCost.compareTo(b.value.systemData.baseCost)
    );

    for (int i = 0; i < quantity; i++) {
      // Weighted random: cheaper items more likely
      final idx = (rnd.nextDouble() * rnd.nextDouble() * availableWeapons.length).toInt();
      items.add(Weapon.fromStock(availableWeapons[idx].key));
    }
  }

}
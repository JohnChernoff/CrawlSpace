import 'dart:math';

import 'package:space_fugue/pilot.dart';
import 'package:space_fugue/rng.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/stock_items/stock_weapons.dart';
import 'package:space_fugue/systems/ship_system.dart';
import 'package:space_fugue/systems/weapons.dart';

import 'item.dart';

class ShopOptions {
  int costRepair = 1, costRecharge = 1, costBioHack = 50, costBroadcast = 2000;
}

enum TransactionResult { ok, insufficientFunds, inventoryError, refusal, wtf}

sealed class Shop {
  String name;
  bool buysScrap;
  List<Item> items = [];
  int credits = 10000;

  Shop(this.name,{this.buysScrap = false});
  void generateItems(double techLvl, Random rnd, {int avgQuantity = 12});

  TransactionResult buyItem(Item item, Ship ship) {
    final pilot = ship.pilot; if (pilot == nobody) return TransactionResult.wtf;
    final price = (item.baseCost / 2).round(); //TODO: some variable?
    if (credits > price) {
      if (pilot.transaction(TransactionType.shopSell,price)) {
        credits -= price;
        ship.jettisonItem(item);
        if (item is ShipSystem) items.add(item); //TODO: generalize
        return TransactionResult.ok;
      }
      else {
        return TransactionResult.wtf;
      }
    } else {
      return TransactionResult.insufficientFunds;
    }
  }

TransactionResult sellItem(Item i, Ship ship) {
    if (items.contains(i)) {
      int price = i.baseCost;
      if (!ship.pilot.transaction(TransactionType.shopBuy,-price)) {
        return TransactionResult.insufficientFunds;
      } else if (ship.addToInventory(i)) {
        items.remove(i);
        credits += price;
        return TransactionResult.ok;
      } else {
        ship.pilot.rollBack();
        return TransactionResult.inventoryError;
      }
    } else {
      return TransactionResult.inventoryError;
    }
  }

  String transaction(Item item,Ship ship, bool buy) {
    if (buy) {
      TransactionResult result = sellItem(item,ship);
      return (switch (result) {
        TransactionResult.ok => "Purchased: $item",
        TransactionResult.insufficientFunds => "You don't have enough credits",
        TransactionResult.inventoryError => "Your ship can't hold that!",
        TransactionResult.refusal => "No way!",
        TransactionResult.wtf => "Wtf!",
      });
    } else {
      TransactionResult result = buyItem(item,ship);
      return (switch (result) {
        TransactionResult.ok => "Sold: $item",
        TransactionResult.insufficientFunds => "The shopkeeper can't afford that!",
        TransactionResult.inventoryError => "The shopkeeper hasn't room for that!",
        TransactionResult.refusal => "No way!",
        TransactionResult.wtf => "Wtf!",
      });
    }
  }
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
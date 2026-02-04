import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:space_fugue/controllers/fugue_controller.dart';
import 'package:space_fugue/controllers/pilot_controller.dart';
import 'package:space_fugue/inputs/confirm_input.dart';
import 'package:space_fugue/shop.dart';
import '../agent.dart';
import '../descriptors.dart';
import '../item.dart';
import '../planet.dart';
import '../player.dart';
import '../ship.dart';
import '../system.dart';
import 'audio_controller.dart';

class PlanetsideController extends FugueController {
  List<Item> shopList = [];
  PlanetsideController(super.fm);

  void launch() {
    fm.player.planet = null;
    fm.menuController.exitInputMode();
    fm.msgController.addMsg("Launching...");
    fm.audioController.newTrack(newMood: MusicalMood.space);
    fm.pilotController.action(fm.player,ActionType.planetLaunch);
  }

  void broadcast() {
    if (!fm.player.starOne) {
      fm.msgController.addMsg("You must first find Star One.");
    }
    else if (fm.player.credits < fm.shopOptions.costBroadcast) {
      fm.msgController.addMsg("You can't afford this (${fm.shopOptions.costBroadcast} credits).");
    } else {
      fm.msgController.addMsg("You broadcast a message of insurrection against the Galactic Federation");
      fm.player.broadcasts++;
      fm.player.credits -= fm.shopOptions.costBroadcast;
      propaganda(fm.player.system, 0, 4, {fm.player.system});
    }
  }

  void propaganda(System system, int level, int depth, Set<System> systems) {
    fm.msgController.addMsg("Undermining system: ${system.name}");
    if (level < depth) {
      system.fedLvl = (system.fedLvl / (depth - level)).floor();
      for (System link in system.links) {
        if (systems.add(link)) {
          propaganda(link, level + 1, depth, systems);
        }
      }
    }
    fm.heat(25,sighted: fm.player.system);
  }

  void getTradeMission() {
    if (fm.playerShip == null) {
      fm.msgController.addMsg("You're not in a ship!");
    } else if (fm.player.tradeTarget?.source == fm.player.planet) {
      fm.msgController.addMsg("You already have a mission from this planet.");
    } else {
      List<System> path = [];
      int steps = 3;
      int r = 100; //(player.techLevel() / 10).ceil() * playerShip!.cargo.value;
      int reward = (r/2).floor() + fm.rnd.nextInt(r);
      Planet? planet; int tries = 0;
      while (planet == null && tries++ < 100) {
        path = [fm.player.system];
        planet = fm.createTradePlanet(path, steps);
      }
      if (planet != null) {
        fm.player.tradeTarget = TradeTarget(planet, fm.player.planet, reward);
        fm.msgController.addMsg("${planet.name} is in desperate need of ${rndEnum(Goods.values.where((g) => g != planet?.export))}, "
            "reward: $reward. Route: ${fm.pathList(path)}");
      } else {
        fm.msgController.addMsg("Failed to find planet in route: ${fm.pathList(path)}");
      }
      fm.pilotController.action(fm.player,ActionType.planet, mod: 1.25);
    }
  }

  void spy() {
    for (Agent agent in fm.agents) {
      if (agent.tracked == 0) {
        agent.track((fm.player.techLevel() / 8).floor() * (fm.techCheck(1) ? 2 : 1));
        List<System>? path = fm.galaxyGraph.shortestPath(fm.player.system, agent.system);
        fm.msgController.addMsg("${agent.name} is ${fm.jumps(path)} jumps away (tracking for ${agent.tracked} jumps)");
      }
    }
    fm.pilotController.action(fm.player,ActionType.planet);
  }

  void hack() { //find starOne
    List<System>? path = fm.galaxyGraph.shortestPath(fm.player.system, fm.starOne());
    fm.msgController.addMsg("Star One is ${fm.jumps(path)} jumps away");
    fm.msgController.addMsg("Next step: ${fm.nextSystemInPath(path)?.name}");
    fm.pilotController.action(fm.player,ActionType.planet,mod: 1.5);
  }

  void scout() {
    int depth = (fm.player.techLevel() / 16).ceil();
    fm.msgController.addMsg("Scouting nearby systems (depth: $depth)...");
    fm.explore(fm.player.system, depth);
    fm.pilotController.action(fm.player,ActionType.planet);
  }

  void bioHack({int amount = 1}) {
    if (fm.player.dnaScram < Player.maxDna) {
      if (fm.player.credits >= fm.shopOptions.costBioHack) {
        fm.player.credits -= fm.shopOptions.costBioHack;
        fm.player.dnaScram++;
        fm.msgController.addMsg("Dna scrambled (mutation: ${fm.player.dnaScram})");
        fm.pilotController.action(fm.player,ActionType.planet,mod: 2);
      } else {
        fm.msgController.addMsg("You can't afford this (cost: ${fm.shopOptions.costBioHack} credits).");
      }
    } else {
      fm.msgController.addMsg("Your system cannot handle further modification.");
    }
  }

  void shop() {
    Planet? planet = fm.player.planet; if (planet != null) { // && planet.commLvl.atOrAbove(DistrictLvl.medium)) {
      planet.shop ??= WeaponShop("Bob's Torpedo Factory"); //TODO: randomize
      if (planet.shop!.items.isEmpty) planet.shop!.generateItems(planet.techLvl/100, fm.rnd);
      fm.menuController.displayShopMenu(planet.shop!);
    }
  }

  //TODO: scrap, shop price modifiers, etc.
  void purchaseItem(String letter) {
    Shop? shop = fm.player.planet?.shop;
    Ship? ship = fm.playerShip;
    if (shop != null && ship != null) {
      Item? i = shop.items.elementAtOrNull(letter.codeUnitAt(0) - 97); if (i == null) return;
      fm.menuController.confirmChoice("Purchse ${i.name} for ${i.baseCost} credits?")
          .then((choice) {
        if (choice == ConfirmAction.yes) {
          final result = shop.sellItem(i, ship); //print("buy: $i, $result");
          if (result == TransactionResult.insufficientFunds) {
            fm.msgController.addMsg("You can't afford it!");
          } else {
            fm.msgController.addMsg("Thanks for shopping at ${shop.name}!");
            fm.menuController.displayShopMenu(shop, changeInputMode: false);
          }
        } else {
          fm.msgController.addMsg("Nevermind, then.");
        }
      });
    }
  }

  void sellItem() {
    Ship? ship = fm.playerShip; if (ship != null) {
      final list = ship.inventory.asList(); list.addAll(ship.scrapHeap.asList());
      fm.menuController.showInventory(list).then((letter) {
        int i = letter.codeUnitAt(0) - 97;
        Item? item = list.elementAtOrNull(i); if (item != null) {
          Shop? shop = fm.player.planet?.shop;
          if (shop != null) {
            final result = shop.buyItem(item,ship); //print("sell: $item, $result");
            if (result == TransactionResult.ok) {
              fm.msgController.addMsg("Sold for ${ship.pilot?.transRec.last.credits.abs()} credits");
            } else if (result == TransactionResult.insufficientFunds) {
              fm.msgController.addMsg("The shopkeeper can't afford that!");
            }
          }
        }
      });
    }
  }

}
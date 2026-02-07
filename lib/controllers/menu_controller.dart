import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:space_fugue/controllers/fugue_controller.dart';
import '../inputs/confirm_input.dart';
import '../item.dart';
import '../planet.dart';
import '../ship.dart';
import '../shop.dart';
import '../system.dart';
import '../systems/ship_system.dart';

enum InputMode {main,menu,hyperspace,planet,repair,shop,broadcast,dnaShop,tavern,confirm}

abstract class MenuEntry {
  final String letter;
  final String label;
  final bool exitMenu;

  MenuEntry(this.letter,this.label,{this.exitMenu = true});

  void activate(MenuController menu);
}

class ActionEntry extends MenuEntry {
  final void Function(MenuController) action;

  ActionEntry(super.letter, super.label, this.action, {super.exitMenu = true});

  @override
  void activate(MenuController menu) {
    action(menu);
    if (exitMenu) {
      menu.exitInputMode();
    } else {
      menu.fm.update();
    }
  }
}

class ValueEntry<T> extends MenuEntry {
  final T value;
  final void Function(T) onSelect;

  ValueEntry(super.letter, super.label, this.value, this.onSelect, {super.exitMenu = true});

  @override
  void activate(MenuController menu) {
    if (exitMenu) {
      menu.exitInputMode();
    } else {
      menu.fm.update();
    }
    onSelect(value);
  }
}

class ResultMessage {
  final bool success;
  final String msg;
  const ResultMessage(this.msg, this.success);
}

class ActionCompleter<T> {
  final Completer<T> _completer = Completer<T>();
  final Function() _onComplete;

  ActionCompleter(this._onComplete);

  Future<T> get future => _completer.future;

  void trigger() {
    _onComplete();
  }

  void complete([T? value]) {
    _onComplete();
    _completer.complete(value);
  }

  void completeError(Object error, [StackTrace? stackTrace]) {
    _onComplete();
    _completer.completeError(error, stackTrace);
  }
}

class MenuController extends FugueController {
  ActionCompleter<ConfirmAction>? confirmationCompleter;
  ActionCompleter<String>? inventoryCompleter;
  List<MenuEntry> selectionList = [];
  List<InputMode> inputStack = [InputMode.main];
  InputMode get inputMode => inputStack.last;
  bool fullscreen = false;

  MenuController(super.fm);

  void newInputMode(InputMode mode) {
    print("Mode: ${inputMode.name} -> ${mode.name}");
    if (inputMode != mode) {
      inputStack.add(mode);
    }
    fm.update();
  }

  InputMode? exitInputMode() {
    final previousMode = (inputStack.length > 1) ? inputStack.removeLast() : null;
    if (previousMode != null) {
      if (previousMode == InputMode.shop && fm.player.planet != null) {
        showPlanetMenu(fm.player.planet!);
      }
    }
    fm.update();
    return previousMode;
  }

  void showHyperSpaceMenu(Map<String,System> currentLinkMap) {
    StringBuffer sb = StringBuffer();
    sb.writeln("Hyperspace Menu");
    for (final letter in currentLinkMap.keys) {
      sb.write("$letter: ${currentLinkMap[letter]}");
    }
    sb.writeln("x: cancel");
    fm.msgController.addMsg(sb.toString());
    newInputMode(InputMode.hyperspace);
  }

  void showPlanetMenu(Planet planet) {
    StringBuffer sb = StringBuffer(); //sb.writeln(planet.description);
    if (planet.resLvl.atOrAbove(DistrictLvl.light)) {
      sb.writeln("(s)cout the system");
    }
    if (planet.resLvl.atOrAbove(DistrictLvl.medium)) {
      sb.writeln("(h)ack the network for clues about Star One");
    }
    if (planet.resLvl.atOrAbove(DistrictLvl.heavy)) {
      sb.writeln("reveal (a)gent locations");
    }
    if (planet.commLvl.atOrAbove(DistrictLvl.light)) {
      sb.writeln("(v)isit the tavern");
    }
    if (planet.commLvl.atOrAbove(DistrictLvl.medium)) {
      sb.writeln("(t)rade mission");
    }
    if (planet.commLvl.atOrAbove(DistrictLvl.heavy)) {
      sb.writeln("(b)roadcast information about Star One");
    }
    if (planet.dustLvl.atOrAbove(DistrictLvl.light)) {
      sb.writeln("(r)epair ship");
    }
    if (planet.dustLvl.atOrAbove(DistrictLvl.medium)) {
      sb.writeln("(u)pgrade ship");
    }
    if (planet.dustLvl.atOrAbove(DistrictLvl.heavy)) {
      sb.writeln("(g)enetic engineering");
    }
    sb.writeln("(l)aunch");
    fm.msgController.addMsg(sb.toString());
    newInputMode(InputMode.planet);
  }

  String letter(int n) => String.fromCharCode(n + 97);

  Future<ConfirmAction> confirmChoice(String msg) {
    fm.msgController.addMsg(msg);
    newInputMode(InputMode.confirm);
    confirmationCompleter = ActionCompleter(exitInputMode);
    return confirmationCompleter!.future;
  }

  List<MenuEntry> createUninstallMenu(Ship ship) {
    final systems = ship.getAllInstalledSystems.toList();
    return <MenuEntry> [
      for (int i = 0; i < systems.length; i++)
        ValueEntry(letter(i),"${systems[i].name} , ${systems[i].slot}", systems[i],
                (system) => fm.msgController.addResultMsg(fm.pilotController.uninstallSystem(system, ship)))
    ];
  }

  List<MenuEntry> createInstallMenu(Ship ship) {
    final systems = ship.uninstalledSystems.toList();
    return <MenuEntry> [
      for (int i = 0; i < systems.length; i++)
        ValueEntry(letter(i),"${systems[i].name} , ${systems[i].slot}", systems[i],
                (system) => fm.pilotController.installSystem(ship, system))
    ];
  }

  List<MenuEntry> createInstallSlotMenu(Ship ship, ShipSystem system) {
    final slots = ship.availableSlots(system).map((s) => s.slot).toList();
    return <MenuEntry> [
      for (int i = 0; i < slots.length; i++)
        ValueEntry(letter(i),"${slots[i]}", slots[i],
                (slot) => fm.msgController.addResultMsg(fm.pilotController.installSystem(ship, system, slot: slot)))
    ];
  }

  List<MenuEntry> createShopMenu(Shop shop, Ship ship) {
    List<Item> items = shop.items; //filters?
    final entries = <MenuEntry> [
      for (int i = 0; i < items.length; i++)
        ValueEntry(letter(i),"${items[i].name} , ${items[i].baseCost}", items[i],
                (item) => fm.msgController.addMsg(shop.transaction(item, ship, true)),
            exitMenu: false)
    ];
    entries.add(ActionEntry("s","(s)ell", (m) => showMenu(createShopSellMenu(ship, shop)),exitMenu: false));
    return entries;
  }

  List<MenuEntry> createShopSellMenu(Ship ship, Shop shop) { //TODO: filter by shop type
    final installed = ship.getAllInstalledSystems;
    final items = ship.inventory.toList().where((i) => !installed.contains(i)).asList();
    return <MenuEntry> [
      for (int i = 0; i < items.length; i++)
        ValueEntry(letter(i),"${items[i].name} , ${items[i].baseCost}", items[i], //TODO: show cost modifier?
                (item) => fm.msgController.addMsg(shop.transaction(item, ship, false)))
    ];
  }

  void showMenu(List<MenuEntry> menuMap, {headerTxt = "Please select:", nothingTxt = "Nothing found"}) {
    StringBuffer sb = StringBuffer();
    if (menuMap.isEmpty) {
      fm.msgController.addMsg(nothingTxt); return;
    } else {
      menuMap.add(ActionEntry("x", "e(x)it", (m) => exitInputMode()));
      selectionList = menuMap;
      sb.writeln(headerTxt);
      for (final e in selectionList) {
        sb.writeln("${e.letter}: ${e.label}");
      }
    }
    fm.msgController.addMsg(sb.toString());
    newInputMode(InputMode.menu);
  }


}
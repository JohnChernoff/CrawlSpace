import 'dart:async';

import 'package:space_fugue/controllers/fugue_controller.dart';
import '../inputs/confirm_input.dart';
import '../item.dart';
import '../planet.dart';
import '../shop.dart';
import '../system.dart';

enum InputMode {main,inventory,hyperspace,planet,repair,shop,broadcast,dnaShop,tavern,confirm}

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

  void displayShopMenu(Shop shop, {bool changeInputMode = true}) {
    StringBuffer sb = StringBuffer();
    for (int i=0; i<shop.items.length;i++) {
      final item = shop.items.elementAt(i);
      sb.writeln("${String.fromCharCode(i + 97)}: ${item.name} , ${item.baseCost}");
    }
    sb.writeln("(s)ell an item");
    sb.writeln("e(x)it shop");
    fm.msgController.addMsg(sb.toString());
    if (changeInputMode) newInputMode(InputMode.shop);
  }

  void exitMode() { //fm.msgController.addMsg("Exiting mode: $inputMode");
    exitInputMode();
  }

  Future<ConfirmAction> confirmChoice(String msg) {
    fm.msgController.addMsg(msg);
    newInputMode(InputMode.confirm);
    confirmationCompleter = ActionCompleter(exitInputMode);
    return confirmationCompleter!.future;
  }

  Future<T?> showInventory<T>(List<T> items, {String? headerTxt, String? nothingTxt, bool changeInputMode = true, bool shopping = false}) {
    inventoryCompleter = ActionCompleter(exitInputMode);
    StringBuffer sb = StringBuffer();
    if (items.isEmpty) {
      fm.msgController.addMsg(nothingTxt ?? "Nothing found");
      inventoryCompleter?.trigger();
      return Future<T?>.value(null);
    } else {
      sb.writeln(headerTxt ?? "Please select:");
      for (int i=0; i<items.length;i++) {
        final item = items.elementAt(i);
        if (shopping && item is Item) {
          sb.writeln("${String.fromCharCode(i + 97)}: ${item.name} , ${item.baseCost}");
        } else {
          sb.writeln("${String.fromCharCode(i + 97)}: $item");
        }
      }
    }
    fm.msgController.addMsg(sb.toString());
    if (changeInputMode) newInputMode(InputMode.inventory);
    return inventoryCompleter!.future
        .then((letter) => items.elementAtOrNull(letter.codeUnitAt(0) - 97));
  }

}
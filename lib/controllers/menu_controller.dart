import 'package:space_fugue/controllers/audio_controller.dart';
import 'package:space_fugue/controllers/fugue_controller.dart';
import 'package:space_fugue/controllers/pilot_controller.dart';
import '../planet.dart';
import '../ship.dart';
import '../system.dart';

enum InputMode {main,inventory,hyperspace,planet,repair,techShop,broadcast,dnaShop,tavern}

class MenuController extends FugueController {
  Map<String,System> currentLinkMap = {};
  InputMode inputMode = InputMode.main;

  MenuController(super.fm);

  void hyperSpaceMenu() {
    Ship? ship = fm.playerShip; if (ship == null) {
      fm.msgController.addMsg("No ship!"); return;
    }
    final cell = ship.loc.cell; if (cell is! SectorCell) {
      fm.msgController.addMsg("Wrong layer!"); return;
    }
    final star = cell.starClass; if (star == null) {
      fm.msgController.addMsg("No star!"); return;
    }
    final system = ship.loc.level; if (system is! System) {
      fm.msgController.addMsg("No system?!"); return;
    }
    StringBuffer sb = StringBuffer();
    sb.writeln("Hyperspace Menu");
    currentLinkMap.clear();
    for (int i=0; i<system.links.length; i++) {
      final link = system.links.elementAt(i);
      String letter = String.fromCharCode(97 + i); // 97 is ASCII for 'a'
      currentLinkMap[letter] = link;
      sb.write("$letter: $link");
    }
    sb.writeln("x: cancel");
    fm.msgController.addMsg(sb.toString());
    inputMode = InputMode.hyperspace;
    fm.pilotController.action(fm.player, ActionType.sector);
  }

  void hyperSpace(String letter) {
    if (currentLinkMap.containsKey(letter)) {
      inputMode = InputMode.main;
      fm.layerTransitController.newSystem(fm.player, currentLinkMap[letter]!);
    }
  }

  void visitPlanet() {
    Ship? ship = fm.playerShip; if (ship == null) {
      fm.msgController.addMsg("No ship!"); return;
    }
    final cell = ship.loc.cell; if (cell is! SectorCell) {
      fm.msgController.addMsg("Wrong layer!"); return;
    }
    final planet = cell.planet; if (planet == null) {
      fm.msgController.addMsg("No planet!"); return;
    }
    inputMode = InputMode.planet;
    StringBuffer sb = StringBuffer();
    sb.writeln(planet.description);
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
    fm.audioController.newTrack(newMood: MusicalMood.planet);
    fm.pilotController.action(fm.player,ActionType.planetLand);
  }

  void cancelToMain() {
    inputMode = InputMode.main;
    fm.update();
  }

}
import 'package:space_fugue/controllers/fugue_controller.dart';
import '../planet.dart';
import '../system.dart';

enum InputMode {main,inventory,hyperspace,planet,repair,techShop,broadcast,dnaShop,tavern}

class MenuController extends FugueController {
  InputMode inputMode = InputMode.main;

  MenuController(super.fm);

  void showHyperSpaceMenu(Map<String,System> currentLinkMap) {
    StringBuffer sb = StringBuffer();
    sb.writeln("Hyperspace Menu");
    for (final letter in currentLinkMap.keys) {
      sb.write("$letter: ${currentLinkMap[letter]}");
    }
    sb.writeln("x: cancel");
    fm.msgController.addMsg(sb.toString());
    inputMode = InputMode.hyperspace;
  }

  void showPlanetMenu(Planet planet) {
    inputMode = InputMode.planet;
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
  }

  void cancelToMain() {
    inputMode = InputMode.main;
    fm.update();
  }

}
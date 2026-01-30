import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:space_fugue/descriptors.dart';
import 'package:space_fugue/fugue_controller.dart';
import 'package:space_fugue/galaxy.dart';
import 'package:space_fugue/impulse.dart';
import 'package:space_fugue/main.dart';
import 'package:space_fugue/pilot.dart';
import 'package:space_fugue/planet.dart';
import 'package:space_fugue/player.dart';
import 'package:space_fugue/rng.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/system.dart';
import 'actions.dart';
import 'agent.dart';
import 'coord_3d.dart';
import 'galaxy_graph.dart';
import 'grid.dart';
import 'location.dart';
import 'message_worker.dart';
import 'options.dart';

enum MusicalMood {intro,danger,planet,space}
enum InputMode {main,inventory,hyperspace,planet,repair,techShop,broadcast,dnaShop,tavern}
enum ScannerMode {
  all,objects,storms,field,ships,planets,stars,ion,neb,roid,oddities;
  bool get scaningShips => this == ScannerMode.ships || this == ScannerMode.objects;
  bool get scaningPlanets => this == ScannerMode.planets || this == ScannerMode.objects;
  bool get scaningStars => this == ScannerMode.stars || this == ScannerMode.objects;
  bool get scaningIons => this == ScannerMode.ion || this == ScannerMode.storms || this == ScannerMode.field;
  bool get scaningNeb => this == ScannerMode.neb || this == ScannerMode.field;
  bool get scaningRoids => this == ScannerMode.roid || this == ScannerMode.field;
  bool get scaningBlackhole => this == ScannerMode.oddities;
  bool get scaningStarOne => this == ScannerMode.oddities;
}
const blownUp = -1;

class FugueModel with ChangeNotifier {
  Galaxy galaxy;
  late GalaxyGraph galaxyGraph; //TODO: replace with https://pub.dev/packages/directed_graph
  late ForceDirectedGraph<System> graph;
  late Player player;
  int numAgents = 3;
  List<Agent> agents = [];
  Random rnd = Random();
  int auTick = 0;
  String? result;
  bool gameOver = false;
  bool victory = false;
  final faker = Faker.instance;
  final msgWorker = MessageQueueWorker();
  int costRepair = 1, costRecharge = 1, costBioHack = 50, costBroadcast = 2000;
  MusicalMood mood = MusicalMood.intro;
  Map<Pilot,Ship> pilotMap = {};
  Set<Pilot> pilots = {};
  ImpulseLocation? get playerImpulseLoc => pilotImpulseLoc(player);
  ImpulseLocation? pilotImpulseLoc(Pilot p) => pilotMap[p]?.loc as ImpulseLocation;
  Ship? get playerShip => pilotMap[player];
  Iterable<Pilot> get activePilots => pilots.where((p) => pilotMap[p] != null);
  Iterable<Pilot> get availablePilots => activePilots.where((p) => p.auCooldown == 0);
  late FugueController controller;
  InputMode inputMode = InputMode.main;
  Map<String,System> currentLinkMap = {};
  ScannerMode scannerMode = ScannerMode.all;

  FugueModel(this.galaxy,String playerName) {
    controller = FugueController(this);
    graph = ForceDirectedGraph<System>(config: const GraphConfig(
      scaling: 0.05,
      repulsion: 180, //92,
      repulsionRange: 512, //360,
      maxStaticFriction: 36,
      elasticity: .5,
      damping: .9,
    ));
    for (System sys in galaxy.systems) {
      graph.addNode(Node(sys));
    }
    for (System sys in galaxy.systems) {
      for (System link in sys.links) {
        addEdge(sys,link);
      }
    }
    galaxyGraph = GalaxyGraph(this);
    List<System>? maxPath; System farthestSystem = galaxy.homeSystem;
    for (System sys in galaxy.systems) {
      List<System>? path = galaxyGraph.shortestPath(sys,galaxy.homeSystem);
      if ((path?.length ?? 0) > (maxPath?.length ?? 0)) {
        maxPath = path; farthestSystem = sys;
      }
    } //print("Max Path: $maxPath");

    player = Player(playerName,farthestSystem);
    player.system.visited = true;
    for (int i=0;i<numAgents;i++) {
      agents.add(Agent("Agent ${faker.name.lastName()}", galaxy.homeSystem, 25));
    }
    final playCell = player.system.map.rndCell(rnd);
    Ship playShip = Ship("HMS Sebastian",
        player,shipClass: ShipClass.mentok,loc: SystemLocation(player.system, playCell));
    pilotMap[player] = playShip;
    for (System sys in galaxy.systems) {
      for (int i=0;i<rnd.nextInt(3);i++) {
        Pilot pilot = Pilot(faker.name.fullName());
        final cell = sys.map.rndCell(rnd);
        Ship ship = Ship("${Rng.rndColorName(rnd)}${faker.animal.snake()}",
            pilot,shipClass: ShipClass.mentok,loc: SystemLocation(sys, cell));
        pilotMap[pilot] = ship;
        pilots.add(pilot);
      }
    }
    update(); //galaxy.rndTest();
  }

  void addEdge(System s1, System s2) {
    Node n1 = graph.nodes.firstWhere((n) => n.data == s1);
    Node n2 = graph.nodes.firstWhere((n) => n.data == s2);
    Edge edge = Edge(n1,n2);
    if (!graph.edges.contains(edge)) {
      graph.addEdge(edge); //print("Adding edge: $edge");
    }
  }

  void hyperSpaceMenu() {
    Ship? ship = playerShip; if (ship == null) {
      addMsg("No ship!"); return;
    }
    final cell = ship.loc.cell; if (cell is! SectorCell) {
      addMsg("Wrong layer!"); return;
    }
    final star = cell.starClass; if (star == null) {
      addMsg("No star!"); return;
    }
    final system = ship.loc.level; if (system is! System) {
      addMsg("No system?!"); return;
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
    addMsg(sb.toString());
    inputMode = InputMode.hyperspace;
    pilotAction(player, ActionType.sector);
  }

  String statusText() {
    StringBuffer sb = StringBuffer();
    sb.writeln("Status: ");
    Ship? ship = playerShip; if (ship == null) {
      sb.writeln("No ship!");
    } else {
      sb.writeln(ship.name);
      sb.writeln(ship.loc.cell);
    }
    return sb.toString();
  }

  String scannerText({ScannerMode? mode}) {
    StringBuffer sb = StringBuffer();
    sb.writeln("Scanner mode: ${scannerMode.name}");
    Ship? ship = playerShip; if (ship == null) {
      sb.writeln("-");
    } else {
      final cells = ship.loc.level.map.cells.values
          .where((c) => c.scannable(ship.loc.level.map, mode ?? scannerMode))
          .sorted((c1,c2) => c1.coord.distance(ship.loc.cell.coord).compareTo(c2.coord.distance(ship.loc.cell.coord)));
      for (GridCell cell in cells) {
        if (!cell.empty(ship.loc.level.map)) {
          sb.writeln(cell.toScannerString(ship.loc.level.map));
        }
      }
    }
    return sb.toString();
  }

  void toggleScannerMode({bool forwards = true}) {
    if (forwards) {
      if (scannerMode.index < ScannerMode.values.length - 1) {
        scannerMode = ScannerMode.values.elementAt(scannerMode.index + 1);
      } else {
        scannerMode = ScannerMode.values.elementAt(0);
      }
    } else {
      if (scannerMode.index > 0) {
        scannerMode = ScannerMode.values.elementAt(scannerMode.index - 1);
      } else {
        scannerMode = ScannerMode.values.elementAt(ScannerMode.values.length - 1);
      }
    }
    notifyListeners();
  }

  void hyperSpace(String letter) {
    if (currentLinkMap.containsKey(letter)) {
      inputMode = InputMode.main;
      newSystem(player, currentLinkMap[letter]!);
    }
  }

  void cancelToMain() {
    inputMode = InputMode.main;
    notifyListeners();
  }

  void visitPlanet() {
    Ship? ship = playerShip; if (ship == null) {
      addMsg("No ship!"); return;
    }
    final cell = ship.loc.cell; if (cell is! SectorCell) {
      addMsg("Wrong layer!"); return;
    }
    final planet = cell.planet; if (planet == null) {
      addMsg("No planet!"); return;
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
    addMsg(sb.toString());
    pilotAction(player,ActionType.planetLand);
  }

  void pilotAction(Pilot? pilot, ActionType actionType, { mod = 1.0, int? actionAuts }) {
    if (pilot == null) return;
    if (actionType.risk > 0 && rnd.nextInt(255) < player.fedLevel()) { //addMsg("You have a bad feeling about this...");
      if (rnd.nextInt(128) < (max(actionType.risk - (actionType.dna ? player.dnaScram : 0),1))) {
        heat(actionType.heat);
      }
    }
    pilot.auCooldown += ((actionAuts ?? actionType.baseAuts) * mod).round();
    pilot.lastAct = actionType;
    update();
    if (pilot == player) runUntilNextPlayerTurn();
  }

  AgentSystemReport agentAt(System system, {bool playerPerspective = true}) {
    AgentSystemReport report = AgentSystemReport.none;
    for (Agent a in agents) { //print("Checking Agent at ${a.system.name}, ${a.lastKnown?.name}, ${a.tracked}");
      if (playerPerspective && a.lastKnown == system) {
        if (a.tracked > 0) {
          return AgentSystemReport.current;
        } else {
          report = AgentSystemReport.lastKnown;
        }
      }
      else if (!playerPerspective && a.system == system) {
        return AgentSystemReport.current;
      }
    }
    return report;
  }

  void outOfEnergy() {
    addMsg("Insufficient energy!");
  }

  bool newSystem(Pilot pilot, System system) {
    if (pilotMap.containsKey(pilot)) {
      Ship ship = pilotMap[pilot]!;
      final sysLoc = ship.loc;
      if (sysLoc is SystemLocation) {
        if (sysLoc.cell.starClass != null) {
          sysLoc.level.map.removeShip(ship);
          final stars = system.map.cells.values.where((c) => c is SectorCell && c.starClass != null);
          ship.loc = SystemLocation(system, stars.first);
          pilotAction(pilot,ActionType.sector);
          return true;
        }
      }
    }
    return false;
  }

  void goPlan(Planet? planet) { //print("Visiting: $planet");
    newTrack(MusicalMood.planet);
    OrbitResult result = OrbitResult.newOrbit; //player.newOrbit(planet);
    if (result == OrbitResult.insufficientEnergy) {
      outOfEnergy();
    } else if (result == OrbitResult.newOrbit) {
      if (planet == galaxy.homeWorld) {
        endGame("You complete your mission!",home: true);
      } else {
        if (planet != null) {
          //if (player.techLevel() > 50 ? !pirateCheck(numPirates: 1) : !pirateCheck()) return;
          addMsg("Orbiting ${planet.name}");
          addMsg(planet.description);
          if (player.tradeTarget?.planet == planet) {
            addMsg("You deliver your cargo.  Reward: ${player.tradeTarget?.reward}");
            player.credits += player.tradeTarget?.reward ?? 0;
            player.tradeTarget = null;
          }
        }
        pilotAction(player,ActionType.planetOrbit);
      }
    } else {
      addMsg("Maintaining orbit around ${planet?.name ?? 'nothing'}",updateAfter: true);
    }
  }

  void endGame(String reason, {bool home = false}) {
    if (home) {
      if (!player.starOne || player.broadcasts == 0) {
        addMsg("You arrive on ${galaxy.homeWorld.name} and are immediately taken into custody and shortly thereafter executed for treason. "
            "Perhaps you should have broadcasted your information to the galaxy first.");
      }
      else if (Rng.biasedRndInt(rnd,mean: 1, min: 0, max: 5) <= player.broadcasts) {
        addMsg("You arrive on ${galaxy.homeWorld.name} admist a media firestorm and are taken into custody, but before your case can be "
            "heard the Federation Government collapses and you are reappointed and promoted to the rank of Intergalactic Commodore ${player.name}. "
            "Congratulations!");
        victory = true;
      } else {
        addMsg("You arrive only to be immediately taken into custody as planet-wide protests echo in the distance.  Unfortunately your arrival also "
        "corresponds with the Intergalactic Foosball Cup and the public's interest in your case wanes.  You eventually wind up exiled on the distant ice planet "
        "Winnipegiax where you helplessly witness the antimatter-annihilation of roughly half the galaxy.");
      }
    }
    result = reason;
    gameOver = true;
    addMsg("*** GAME OVER ***");
    update();
  }

  void launch() {
    player.planet = null; //still orbiting planet
    player.landed = false;
    inputMode = InputMode.main;
    addMsg("Launching...");
    pilotAction(player,ActionType.planetLaunch);
  }

  String starDate() {
    return "$auTick.";
  }

  System starOne() {
    return galaxy.systems.firstWhere((s) => s.starOne);
  }

  System? nextSystemInPath(List<System>? path) {
    if (path == null) return null;
    return path.elementAt(path.length > 1 ? 1 : 0);
  }

  //normal: true if repeatedly below level, inverted: true if repeatedly above level (less likely)
  bool techCheck(int passes, {bool invert = false}) {
    for (int i=0;i<passes;i++) {
      if (rnd.nextInt(100) > (invert ? 100 - player.techLevel() : player.techLevel())) return false;
    }
    return true;
  }

  bool fedCheck(int passes, {bool invert = false}) {
    for (int i=0;i<passes;i++) {
      if (rnd.nextInt(100) > (invert ? 100 - player.fedLevel() : player.fedLevel())) return false;
    }
    return true;
  }

  String pathList(List<System> path) {
    StringBuffer sb = StringBuffer();
    for (System link in path) {
      sb.write(link.name);
      if (link != path.last) sb.write(" -> ");
    }
    return sb.toString();
  }

  void landCheck() {
    if (!player.landed) {
      addMsg("Landing on ${player.planet?.name}...");
      player.landed = true;
      pilotAction(player,ActionType.planetLand);
    }
  }

  int jumps(List<System>? path) => (path?.length ?? 0) - 1;

  void spy() {
    for (Agent agent in agents) {
      if (agent.tracked == 0) {
        agent.track((player.techLevel() / 8).floor() * (techCheck(1) ? 2 : 1));
        List<System>? path = galaxyGraph.shortestPath(player.system, agent.system);
        addMsg("${agent.name} is ${jumps(path)} jumps away (tracking for ${agent.tracked} jumps)");
      }
    }
    pilotAction(player,ActionType.planet);
  }

  void hack() { //find starOne
    List<System>? path = galaxyGraph.shortestPath(player.system, starOne());
    addMsg("Star One is ${jumps(path)} jumps away");
    addMsg("Next step: ${nextSystemInPath(path)?.name}");
    pilotAction(player,ActionType.planet,mod: 1.5);
  }

  void scout() {
    int depth = (player.techLevel() / 16).ceil();
    addMsg("Scouting nearby systems (depth: $depth)...");
    explore(player.system, depth);
    pilotAction(player,ActionType.planet);
  }

  void explore(System system,int depth) { //addMsg("Exploring: ${system.name} , depth: $depth");
    system.scout();
    if (depth == 0) return;
    for (System link in system.links) {
      if (!link.scouted) explore(link,depth-1);
    }
  }

  void tradeMission() {
    if (playerShip == null) {
      addMsg("You're not in a ship!");
    } else if (player.tradeTarget?.source == player.planet) {
      addMsg("You already have a mission from this planet.");
    } else {
      List<System> path = [];
      int steps = 3;
      int r = 100; //(player.techLevel() / 10).ceil() * playerShip!.cargo.value;
      int reward = (r/2).floor() + rnd.nextInt(r);
      Planet? planet; int tries = 0;
      while (planet == null && tries++ < 100) {
        path = [player.system];
        planet = createTradePlanet(path, steps);
      }
      if (planet != null) {
        player.tradeTarget = TradeTarget(planet, player.planet, reward);
        addMsg("${planet.name} is in desperate need of ${rndEnum(Goods.values.where((g) => g != planet?.export))}, "
            "reward: $reward. Route: ${pathList(path)}");
      } else {
        addMsg("Failed to find planet in route: ${pathList(path)}");
      }
      pilotAction(player,ActionType.planet, mod: 1.25);
    }
  }

  Planet? createTradePlanet(List<System> path,int steps) {
    if (steps < 1 && path.last.planets.isNotEmpty) {
      return path.last.planets.elementAt(rnd.nextInt(path.last.planets.length));
    } else {
      Set<System> links = path.last.links;
      List<System> unvisitedLinks = links.where((link) => !path.contains(link)).toList();
      if (unvisitedLinks.isNotEmpty) {
        unvisitedLinks.shuffle();
        path.add(unvisitedLinks.first);
        return createTradePlanet(path, steps-1);
      } else { //print("Trade error, steps: $steps, path: $path");
        return null;
      }
    }
  }

  energyScoop() {
    Ship? ship = playerShip;
    if (ship == null) {
      addMsg("You're not in a ship."); return;
    }
    if (player.orbiting != null) {
      goPlan(null); return;
    }
    //if (player.lastAct == ActionType.energyScoop && !pirateCheck(numPirates: 2)) return;
    double amount = 50;
    //((ship.energyConvertor.value/(Rng.biasedRndInt(rnd,mean: 50, min: 25, max: 80))) * player.system.starClass.power).floor();
    addMsg("Scooping class ${player.system.starClass.name} star... gained ${ship.recharge(amount)} energy");
    pilotAction(player,ActionType.energyScoop);
  }



  void heat(int v, {System? sighted}) {
    for (Agent agent in agents) {
      agent.clueLvl = min(agent.clueLvl + v,100);
      if (sighted != null) agent.sighted = sighted;
    }
    String heatAdj = switch(v) {
      < 5 => "a bit",
      < 12 => "significantly",
      < 24 => "much",
      int() => "massively"
    };
    addMsg("The galaxy just got $heatAdj more dangerous."); //(+$v)");
  }

  void broadcast() {
    if (!player.starOne) {
      addMsg("You must first find Star One.");
    }
    else if (player.credits < costBroadcast) {
      addMsg("You can't afford this ($costBroadcast credits).");
    } else {
      addMsg("You broadcast a message of insurrection against the Galactic Federation");
      player.broadcasts++; player.credits -= costBroadcast;
      propaganda(player.system, 0, 4, {player.system});
      heat(25,sighted: player.system);
    }
  }

  void propaganda(System system, int level, int depth, Set<System> systems) {
    addMsg("Undermining system: ${system.name}");
    if (level < depth) {
      system.fedLvl = (system.fedLvl / (depth - level)).floor();
      for (System link in system.links) {
        if (systems.add(link)) {
          propaganda(link, level + 1, depth, systems);
        }
      }
    }
  }

  int currentHeat() {
    return (agents.fold(0, (pv,e) => pv + e.clueLvl) / agents.length).floor();
  }

  void warp(Ship ship) {
    System system = galaxy.getRandomLinkableSystem(player.system, ignoreTraffic: true) ?? galaxy.getRandomSystem(player.system);
    if (newSystem(player,system)) {
      //ship.warps.value--;
      addMsg("*** EMERGENCY WARP ACTIVATED ***");
      if (ship.pilot == player) {
        for (Agent agent in agents) {
          agent.clueLvl = 25;
        }
      }
    }
    pilotAction(ship.pilot,ActionType.warp);
  }

  void createImpulse({int gridSize = 8, int minDist = 4}) {
    Ship? playShip = playerShip;
    if (playShip == null) {
      addMsg("You're not in a ship."); return;
    }
    int size = gridSize;
    ImpulseLevel impLevel;
    ShipLocation l = playShip.loc;
    if (l is SystemLocation) {
      final rnd = Random(l.cell.impulseSeed);
      if (l.level.impMapCache.containsKey(l.cell)) {
        impLevel = l.level.impMapCache[l.cell]!;
      }
      else {
        Map<Coord3D,ImpulseCell> cells = {};
        for (int x=0;x<size;x++) {
          for (int y=0;y<size;y++) {
            for (int z=0;z<size;z++) {
              final c = Coord3D(x, y, z);
              cells.putIfAbsent(c, () => ImpulseCell(c,
                  wakeTurb: c.isEdge(size) ? 1 : 0
              ));
            }
          }
        }
        impLevel = ImpulseLevel(ImpulseMap(size,cells),l.cell);
        l.level.impMapCache.putIfAbsent(l.cell, () => impLevel);
      }

      final ships = l.level.map.shipMap[l.cell]?.toList();
      if (ships != null && ships.isNotEmpty) {
        ships.remove(playShip);
        final playerCoord = Coord3D.random(size, rnd);
        List<GridCell> safeDistCoords; do {
          safeDistCoords = impLevel.map.cells.values.where((c) => c.coord.distance(playerCoord) >= minDist).toList();
          minDist--;
        } while (safeDistCoords.length < ships.length);
        safeDistCoords.shuffle(rnd);
        for (int i = 0; i < ships.length; i++) {
          enterImpulse(impLevel,ships.elementAt(i));
        }
      }
    }
  }

  void enterImpulse(ImpulseLevel impLvl, Ship? ship, {ImpulseCell? cell, safeDist = 4}) {
    if (ship == null) return;
    final sysLoc = ship.loc;
    if (sysLoc is SystemLocation) {
      GridCell targetCell = cell ?? impLvl.map.rndCell(rnd);
      final pic = playerImpulseLoc;
      if (ship.npc && pic != null && pic.systemLoc.cell == sysLoc.cell && targetCell.coord.distance(pic.cell.coord) < safeDist) {
        List<GridCell> safeDistCells;
        do {
          safeDistCells = impLvl.map.cells.values.where((c) => c.coord.distance(pic.cell.coord) >= safeDist).toList();
          safeDist--;
        } while (safeDistCells.isEmpty);
        safeDistCells.shuffle(rnd);
        targetCell = safeDistCells.first;
      }
      sysLoc.level.map.addShip(ship, targetCell);
      ship.loc = ImpulseLocation(sysLoc, impLvl, targetCell);
    }
  }

  void exitImpulse(Ship? ship) {
    if (ship == null) return;
    final impLoc = ship.loc;
    if (impLoc is ImpulseLocation) {
      impLoc.level.map.removeShip(ship);
      ship.loc = impLoc.systemLoc;
    }
  }

  void vectorShip(Ship? ship, Coord3D v) {
    if (ship == null) return;
    moveShip(ship, ship.loc.cell.coord.add(v));
  }

  void moveShip(Ship? ship, Coord3D c) {
    if (ship == null) return;
    glog("Moving ${ship.name} => $c");
    final l = ship.loc;
    GridCell? destination = l.level.map.cells[c];
    if (destination != null) {
      final dist = l.cell.coord.distance(destination.coord);
      l.level.map.removeShip(ship);
      l.level.map.addShip(ship, destination);
      if (l is SystemLocation) {
        ship.loc = SystemLocation(l.level,destination); //TODO: sublight engine?
        //ship.pilot?.auCooldown += (ship.subLightEngine.baseAutPerUnitTraversal * dist).round();
        pilotAction(ship.pilot, ActionType.movement);
      } else if (l is ImpulseLocation) {
        final engine = ship.impEngine;
        if (engine != null) {
          ship.loc = ImpulseLocation(l.systemLoc,l.level,destination);
          pilotAction(ship.pilot, ActionType.movement,actionAuts: (engine.baseAutPerUnitTraversal * dist).round());
        }
      }
    }
  }

  int score() => auTick + (player.starOne ? 500 : 0) + (galaxy.discoveredSystems() * 2) + (player.piratesVanquished * 3) + (victory ? 1000 : 0);

  void addMsg(String txt, {int delay = 100, bool updateAfter = false, Color color = Colors.white}) {
    msgWorker.addMsg(Message(text: txt, timestamp: starDate(),color: color),delay: delay);
    if (updateAfter) update();
  }

  void runUntilNextPlayerTurn() {
    do {
      for (Pilot p in activePilots) {
        p.tick();
        if (p.ready && pilotMap[p]!.loc.level == playerShip?.loc.level) {
          vectorShip(pilotMap[p]!,Rng.rndUnitVector(rnd));
        }
      }
      auTick++;
      player.tick();
    } while (!player.ready);
    update();
  }

  Future<void> update() async {
    if (!msgWorker.isProcessing || msgWorker.processNotifier.isCompleted) { //print("Updating...");
      notifyListeners();
    } else { //print("Waiting on message queue...");
      msgWorker.processNotifier.future.then((v) { //print("Message queue clear, updating...");
        notifyListeners();
      });
    }
  }

  void glog(String msg) {
    print(msg);
  }

  bool isPlayingMusic() => fuguePlayer.state == PlayerState.playing || fuguePlayer.state == PlayerState.completed;
  void newTrack(MusicalMood moo) {
    if (isPlayingMusic() && mood != moo) {
      mood = moo;
      if (fuguePlayer.state == PlayerState.playing) {
        fuguePlayer.stop().then((v) => fuguePlayer.play(AssetSource(getTrack())));
      } else {
        fuguePlayer.play(AssetSource(getTrack()));
      }
    }
  }
  String getTrack() => switch(mood) {
      MusicalMood.danger => "audio/tracks/danger${rnd.nextInt(4)+1}.mp3",
      MusicalMood.planet => "audio/tracks/planet${rnd.nextInt(4)+1}.mp3",
      MusicalMood.space => "audio/tracks/wandering${rnd.nextInt(4)+1}.mp3",
      MusicalMood.intro => "audio/tracks/intro1.mp3",
  };
}
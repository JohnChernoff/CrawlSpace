import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:space_fugue/descriptors.dart';
import 'package:space_fugue/galaxy.dart';
import 'package:space_fugue/main.dart';
import 'package:space_fugue/planet.dart';
import 'package:space_fugue/player.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/system.dart';
import 'agent.dart';
import 'galaxy_graph.dart';
import 'message_worker.dart';
import 'options.dart';

enum MusicalMood {intro,danger,planet,space}
const blownUp = -1;

class FugueModel with ChangeNotifier {
  Galaxy galaxy;
  late GalaxyGraph galaxyGraph; //TODO: replace with https://pub.dev/packages/directed_graph
  late ForceDirectedGraph<System> graph;
  late Player player;
  int numAgents = 3;
  List<Agent> agents = [];
  Random rnd = Random();
  int turn = 0;
  String? result;
  bool gameOver = false;
  bool victory = false;
  final faker = Faker.instance;
  final msgWorker = MessageQueueWorker();
  int costRepair = 1, costRecharge = 1, costBioHack = 50, costBroadcast = 2000;
  MusicalMood mood = MusicalMood.intro;

  FugueModel(this.galaxy,String playerName) {
    player = Player(playerName,galaxy.homeSystem);
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
    player.system = farthestSystem;
    player.system.visited = true;
    for (int i=0;i<numAgents;i++) {
      agents.add(Agent("Agent ${faker.name.lastName()}", galaxy.homeSystem, 25));
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

  void playAction(ActionType actionType, { mod = 1.0, int? subTurns }) {
    if (actionType.risk > 0 && rnd.nextInt(255) < player.fedLevel()) { //addMsg("You have a bad feeling about this...");
      if (rnd.nextInt(128) < (max(actionType.risk - (actionType.dna ? player.dnaScram : 0),1))) {
        heat(actionType.heat);
      }
    }
    int t = player.action(actionType,modifier: mod, subTurns: subTurns);
    if (t == 0) {
      update();
    } else {
      for (int i=0; i<t; i++) {
        endTurn(); //updates
      }
    }
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

  void moveAgent(Agent agent) {
    for (int t = 0; t < agent.movesPerTurn(); t++) {
      agent.investigate(agent.pickLink(this));
      if (agent.system == player.system) {
        if (player.planet == null) {
          agentBattle(agent);
        } else {
          endGame("${agent.name} found ${player.name}!");
          return;
        }
      }
    }
  }

  void agentBattle(Agent agent) { //TODO: use warps?
    agent.lastKnown = agent.system;
    int agentHP = 100;
    bool escaped = false;
    while (!escaped) {
      addMsg("You have been detected by ${agent.name} and must escape the sector...");
      if ((rnd.nextInt(player.ship.speed.max()) + player.ship.speed.min())  < player.ship.speed.value) {
        addMsg("You activate the afterburners and blast away in the nick of time!");
        escaped = true;
      } else {
        int dam = rnd.nextInt(player.ship.weapons.value) * 2;
        addMsg("You blast ${agent.name} for $dam damage",delay: 500);
        agentHP -= dam;
        if (agentHP <= 0) {
          addMsg("You've disabled their ship!");
          escaped = true;
        }
        else {
          dam = rnd.nextInt(player.ship.hull.max());
          addMsg("You've been blasted for $dam damage");
          if (player.ship.takeDamage(dam)) {
            endGame("Blown up by ${agent.name}");
            return;
          }
        }
      }
    }
  }

  void endTurn() {
    for (Agent a in agents) {
      moveAgent(a);
    }
    turn++;
    update();
  }

  void outOfEnergy() {
    addMsg("Insufficient energy!");
  }

  void goLink(System system) {
    newTrack(MusicalMood.space);
    if (!player.system.links.contains(system)) {
      addMsg("You can't get there yet.");
    } else {
      if (player.planet != null) { //addMsg("You must first take off.");
        launch();
      }
      if (player.newSystem(system)) {
        if (system.starOne) {
          player.starOne = true;
          addMsg("Star One located!  Proceed to ${galaxy.systems.first.name}.");
        }
        system.visited = true; //TODO: check for agents?
        playAction(ActionType.sector);
        if (!gameOver && fugueOptions.getBool(FugueOption.autoScoop)) {
          energyScoop();
        }
      } else {
        outOfEnergy();
      }
    }
  }

  void goPlan(Planet? planet) { //print("Visiting: $planet");
    newTrack(MusicalMood.planet);
    OrbitResult result = player.newOrbit(planet);
    if (result == OrbitResult.insufficientEnergy) {
      outOfEnergy();
    } else if (result == OrbitResult.newOrbit) {
      if (planet == galaxy.homeWorld) {
        endGame("You complete your mission!",home: true);
      } else {
        if (planet != null) {
          if (player.techLevel() > 50 ? !pirateCheck(numPirates: 1) : !pirateCheck()) return;
          addMsg("Orbiting ${planet.name}");
          addMsg(planet.description);
          if (player.tradeTarget?.planet == planet) {
            addMsg("You deliver your cargo.  Reward: ${player.tradeTarget?.reward}");
            player.credits += player.tradeTarget?.reward ?? 0;
            player.tradeTarget = null;
          }
        }
        playAction(ActionType.planetOrbit);
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
      else if (galaxy.biasedRndInt(mean: 1, min: 0, max: 5) <= player.broadcasts) {
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
    playAction(ActionType.planetLaunch);
  }

  String starDate() {
    return "$turn.${player.subTurnCounter}";
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
      playAction(ActionType.planetLand);
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
    playAction(ActionType.planet);
  }

  void hack() { //find starOne
    List<System>? path = galaxyGraph.shortestPath(player.system, starOne());
    addMsg("Star One is ${jumps(path)} jumps away");
    addMsg("Next step: ${nextSystemInPath(path)?.name}");
    playAction(ActionType.planet,mod: 1.5);
  }

  void scout() {
    int depth = (player.techLevel() / 16).ceil();
    addMsg("Scouting nearby systems (depth: $depth)...");
    explore(player.system, depth);
    playAction(ActionType.planet);
  }

  void explore(System system,int depth) { //addMsg("Exploring: ${system.name} , depth: $depth");
    system.scout();
    if (depth == 0) return;
    for (System link in system.links) {
      if (!link.scouted) explore(link,depth-1);
    }
  }

  void tradeMission() {
    if (player.tradeTarget?.source == player.planet) {
      addMsg("You already have a mission from this planet.");
    } else {
      List<System> path = [];
      int steps = 3;
      int r = (player.techLevel() / 10).ceil() * player.ship.cargo.value;
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
      playAction(ActionType.planet, mod: 1.25);
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

  void modShip(ShipSystem shipSys) {
      int change = shipSys.modify(1);
      if (change > 0) {
        int cost = shipSys.type.cost * change;
        if (player.credits < cost) {
          addMsg("You can't afford this.");
          shipSys.modify(-change);
        } else {
          player.credits -= cost;
          addMsg("Modified for $cost credits.");
        }
      }
      playAction(ActionType.planet, mod: .1);
  }

  void repair({all=false,int amount = 1,bool update = true}) {
    int n = (all || amount > player.ship.damage ? player.ship.damage : amount);
    int debt = n * costRepair;
    if (player.credits < debt) {
      n = (player.credits / costRepair).floor(); debt = n * costRepair;
      addMsg("You can't afford that much; repairing as much as possible...");
    }
    player.ship.repair(n);
    player.credits -= debt;
    addMsg("$n damage repaired ($debt credits).",updateAfter: update);
  }

  void recharge({all=false,int amount = 1,bool free = false, bool update = true}) {
    int spentCharge = player.ship.battery.value - player.ship.energy;
    int n = (all || amount > spentCharge ? spentCharge : amount);
    int debt = 0;
    if (!free) {
      debt = n * costRecharge;
      if (player.credits < debt) {
        n = (player.credits / costRecharge).floor(); debt = n * costRecharge;
        addMsg("You can't afford that much; recharging as much as possible...");
      }
      player.credits -= debt;
    }
    player.ship.recharge(n);
    addMsg("$n energy recharged ${debt > 0 ? '($debt credits)' : ''}.",updateAfter: update);
  }

  energyScoop() {
    if (player.orbiting != null) {
      goPlan(null); return;
    }
    if (player.lastAct == ActionType.energyScoop && !pirateCheck(numPirates: 2)) return;
    int amount = ((player.ship.energyConvertor.value/(galaxy.biasedRndInt(mean: 50, min: 25, max: 80))) * player.system.starClass.power).floor();
    addMsg("Scooping class ${player.system.starClass.name} star... gained ${player.ship.recharge(amount)} energy");
    playAction(ActionType.energyScoop);
  }

  void bioHack({int amount = 1}) {
    if (player.dnaScram < Player.maxDna) {
      if (player.credits >= costBioHack) {
        player.credits -= costBioHack;
        player.dnaScram++;
        addMsg("Dna scrambled (mutation: ${player.dnaScram})");
        playAction(ActionType.planet,mod: 2);
      } else {
        addMsg("You can't afford this (cost: $costBioHack credits).");
      }
    } else {
      addMsg("Your system cannot handle further modification.");
    }
  }

  void shoplift() {
    if (player.planet == null) return;
    bool success = rnd.nextInt(300) < (player.thievery + 200);
    if (success) {
      int n = ((player.techLevel()/3) + (player.planet!.commLvl.index * 12)).floor();
      int c = rnd.nextInt(n);
      player.credits += c;
      addMsg("You stole $c credits.");
      playAction(ActionType.planet);
    }
    else {
      heat((2 * (player.fedLevel()/12)).ceil());
      int penalty = rnd.nextInt(67) + 33;
      int t = rnd.nextInt(3) + 2;
      addMsg("You've been caught!  Penalty: $penalty credits and $t turns in jail.");
      player.credits -= penalty;
      if (player.credits < 0) {
        int t2 = (player.credits.abs() / 20).ceil();
        addMsg("You can't afford the fine! Penalty: $t2 extra turns in jail.");
        player.credits = 0;
      }
      playAction(ActionType.planet,subTurns: t * 100);
    }
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

  bool pirateCheck({int? numPirates, int meanPirates = 2, minPirates = 1, maxPirates = 3}) {
    if (fedCheck(3,invert: true)) {
      if (pirateAttack(numPirates ??
          galaxy.biasedRndInt(mean: meanPirates, min: minPirates, max: maxPirates))) {
        endGame("Blown up by pirates");
        return false;
      }
    }
    return true;
  }

  bool pirateAttack(int n, {int delay = 500})  {
    newTrack(MusicalMood.danger);
    if (fugueOptions.getBool(FugueOption.fastCombat)) delay = 50;
    int shields = player.ship.shields.value;
    for (int i = 0; i < n; i++) {
      player.piratesEncountered++;
      Ship pirateShip = Ship("The Dread Pirate ${faker.name.lastName()}",
          weapons: galaxy.biasedRndInt(mean: 8, min: 1, max: 24),
          shields: galaxy.biasedRndInt(mean: 16, min: 8, max: 36),
          hull: galaxy.biasedRndInt(mean: 24, min: 12, max: 48));
      addMsg("${pirateShip.name} ambushes you!");
      shields = battle(pirateShip, delay: delay);
      if (shields == blownUp) return true;
      player.piratesVanquished++;
    }
    return false;
  }

  void piracy() {
    int fedLevel = player.planet?.fedLvl ?? player.system.fedLvl;
    if (Random().nextInt(100) > fedLevel) {
      int c = galaxy.biasedRndInt(mean: 50, min: 1, max: 100);
      addMsg("You successfully shake down a poor innocent space commuter for $c credits and some fuel...");
      player.credits += c;
      recharge(amount: galaxy.biasedRndInt(mean: 50, min: 1, max: 100),free: true,update: false);
      heat(10);
      if (!pirateCheck()) return;
    } else {
      newTrack(MusicalMood.danger);
      addMsg("A Federal Agent intervenes!");
      if (battle(Ship("Federal Agent ${faker.name.lastName()}",weapons: 80, hull: 50, shields: 25)) == blownUp) {
        endGame("Blown up by Federal Agents"); return;
      } else {
        heat(20);
      }
    }
    playAction(ActionType.piracy);
  }

  int battle(Ship opponent, {int? currentShields, int delay = 500}) {
    int shields = currentShields ??  player.ship.shields.value;
    while (opponent.damage < opponent.hull.value) {
      if (Random().nextInt(100) < opponent.weaponType.accuracy) {
        int dam = opponent.fireWeapon(galaxy);
        if (shields > 0) {
          shields -= dam;
          addMsg("Your shields absorb $dam damage (remaining strength: $shields)", delay: delay, color: Colors.purple);
        } else {
          if (player.ship.takeDamage(dam)) {
            addMsg("${opponent.name} blows you up with $dam damage (${player.ship.damageReport()})", delay: delay, color: Colors.red);
            return blownUp;
          } else {
            addMsg("${opponent.name} does $dam damage (${player.ship.damageReport()})", delay: delay, color: Colors.pink);
          }
        }
      } else {
        addMsg("${opponent.name} misses!");
      }
      if (Random().nextInt(100) < player.ship.weaponType.accuracy) {
        int dam = player.ship.fireWeapon(galaxy);
        if (opponent.shields.value > 0) {
          opponent.shields.value -= dam;
          addMsg("${opponent.name}'s shields absorb $dam damage (remaining strength: ${opponent.shields.value})", delay: delay, color: Colors.green);
        } else {
          if (opponent.takeDamage(dam)) {
            addMsg("You blow up ${opponent.name} ($dam damage)!", delay: delay, color: Colors.yellowAccent);
          } else {
            addMsg("You do $dam damage (${opponent.damageReport()})", delay: delay, color: Colors.greenAccent);
          }
        }
      } else {
        addMsg("You miss!");
      }
    }
    return max(0,shields);
  }

  void warp() {
    if (player.ship.energy < player.ship.warpEngine) {
      player.ship.energy = player.ship.warpEngine;
      if (player.ship.takeDamage(rnd.nextInt(player.ship.warpEngine))) {
        endGame("Blown up trying to warp"); return;
      }
    }
    if (player.ship.warps.value > 0) {
      System system = galaxy.getRandomLinkableSystem(player.system, ignoreTraffic: true) ?? galaxy.getRandomSystem(player.system);
      if (player.newSystem(system,warp: true)) {
        player.ship.warps.value--;
        addMsg("*** EMERGENCY WARP ACTIVATED ***");
        for (Agent agent in agents) {
          agent.clueLvl = 25;
        }
        playAction(ActionType.warp);
      }
    } else {
      addMsg("Out of emergency warps.");
    }
  }

  int score() => turn + (player.starOne ? 500 : 0) + (galaxy.discoveredSystems() * 2) + (player.piratesVanquished * 3) + (victory ? 1000 : 0);

  void addMsg(String txt, {int delay = 100, bool updateAfter = false, Color color = Colors.white}) {
    msgWorker.addMsg(Message(text: txt, timestamp: starDate(),color: color),delay: delay);
    if (updateAfter) update();
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
import 'dart:math';
import 'descriptors.dart';
import 'name_generator.dart';
import 'planet.dart';
import 'rng.dart';
import 'system.dart';

class Galaxy {
  static const int density = 25;
  static const int maxSystems = 250;
  static const int avgPlanets = 3, maxPlanets = 6;
  static const int avgLinks = 3, maxLinks = 9;
  Random rnd;
  String name;
  List<System> systems = [];
  NameGenerator nameGenerator;
  Planet homeWorld = Planet("Xaxle", 100, 100, DistrictLvl.heavy, DistrictLvl.heavy, DistrictLvl.heavy, PlanetAge.established, EnvType.earthlike, Goods.soylentPuce);
  late System homeSystem;

  Galaxy(this.name, {int? seed}) : rnd = seed != null ?  Random(seed) : Random(), nameGenerator = NameGenerator(seed ?? 1) {
    homeSystem = System("Mentos", StellarClass.K, 100, 100, [homeWorld], rnd, connected: true);
    systems.add(homeSystem);
    createMap();
    for (System system in systems) {
      system.updateLevels(rnd);
    }
    getRandomLinkableSystem(homeSystem)?.starOne = true;
    getRandomLinkableSystem(homeSystem)?.blackHole = true;
  }

  void createMap() {
    while (systems.length < maxSystems) {
      int n = Rng.biasedRndInt(rnd,mean: avgPlanets, min: 0, max: maxPlanets);
      String name;
      do { name = nameGenerator.generateSystemName(); }
      while (systems.where((sys) => sys.name == name).isNotEmpty);
      int fedLvl = rnd.nextInt(100);
      int techLvl = rnd.nextInt(100);
      System system = System(name,getRndStellarClass(),fedLvl,techLvl,
          generatePlanets(n,fedLvl, techLvl),rnd,traffic: getRndTrafficLvl());
      systems.add(system);
    }
    for (System system in systems) {
      while (!system.addLink(getRandomSystem(system),update: false)) {}
    }
    for (System system in systems) {
      if (!system.connected) { //print("Connecting unconnected system: ${system.name}");
        system.addLink(getRandomSystem(system,connected: true),update: true);
      }
    }
  }

  int discoveredSystems() => systems.where((s) => s.visited).length;

  System getRandomSystem(System system,{bool? connected}) {
    Iterable<System> sysList = systems.where((sys) =>
    (connected == null || sys.connected == connected) && sys != system);
    if (sysList.isEmpty) return systems.first;
    return sysList.elementAt(rnd.nextInt(sysList.length));
  }

  System? getRandomLinkableSystem(System sys, {bool ignoreTraffic = false}) {
    Iterable<System> linkableSystems = systems.where((s) => s != sys && !s.links.contains(sys) && s.links.length < maxLinks && s.traffic == TrafficLvl.hub);
    if (linkableSystems.isEmpty || rnd.nextInt(100) < 33 || ignoreTraffic) {
      linkableSystems = systems.where((s) => s != sys && !s.links.contains(sys) && s.links.length < maxLinks && s.traffic != TrafficLvl.culDeSac);
    }
    if (linkableSystems.isEmpty) return null;
    return linkableSystems.elementAt(rnd.nextInt(linkableSystems.length));
  }

  TrafficLvl getRndTrafficLvl() {
    return switch(rnd.nextInt(100)) {
      > 95 => TrafficLvl.culDeSac,
      < 10 => TrafficLvl.hub,
      int() => TrafficLvl.normal,
    };
  }

  DistrictLvl getRndDistrictLvl() {
    int n = rnd.nextInt(DistrictLvl.values.length);
    return DistrictLvl.values.elementAt(n);
  }

  StellarClass getRndStellarClass() {
    final totalWeight = StellarClass.values.fold<int>(0, (sum, sc) => sum + sc.prob);
    final target = rnd.nextInt(totalWeight);
    int cumulative = 0;
    for (final sc in StellarClass.values) {
      cumulative += sc.prob;
      if (target < cumulative) return sc;
    }
    return StellarClass.values.last; // Fallback (should never happen)
  }

  Planet createPlanet(int sysFed, int sysTech) {
    return Planet(nameGenerator.generatePlanetName(),
        Rng.biasedRndInt(rnd,mean: sysFed, min: 0, max: 100),
        Rng.biasedRndInt(rnd,mean: sysTech, min: 0, max: 100),
        getRndDistrictLvl(),getRndDistrictLvl(),getRndDistrictLvl(),
        PlanetAge.values.elementAt(rnd.nextInt(PlanetAge.values.length)),
        EnvType.values.elementAt(rnd.nextInt(EnvType.values.length)),
        Goods.values.elementAt(rnd.nextInt(Goods.values.length)));
  }

  List<Planet> generatePlanets(int numPlanets, int sysFed, int sysTech) {
    List<Planet> planList = [];
    for (int i=0;i<numPlanets;i++) {
      planList.add(createPlanet(sysFed,sysTech));
    }
    return planList;
  }


}





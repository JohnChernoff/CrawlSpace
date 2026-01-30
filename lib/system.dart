import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:space_fugue/planet.dart';
import 'package:space_fugue/rng.dart';
import 'coord_3d.dart';
import 'grid.dart';
import 'impulse.dart';

enum TrafficLvl { normal, culDeSac, hub }

enum StellarClass {
  O(Color(0xFF3456EE),100,4),
  B(Color(0xFFAABEFF),75,12),
  A(Color(0xFFD5E0FE),60,20),
  F(Color(0xFFF8F5FF),50,32),
  G(Color(0xFFFFEDE2),36,48),
  K(Color(0xFFFFD9B5),25,75),
  M(Color(0xFFFFB56C),12,100);
  final Color color;
  final int power;
  final int prob;
  const StellarClass(this.color,this.power,this.prob);
}

class SystemMap extends Grid<SectorCell> {
  SystemMap(super.size, super.cells);

  void growNebula(SectorCell cell, double strength, Random rnd, {spreadFactor = .25}) {
    cell.nebula = strength;
    double nebulaSpreadProb = (rnd.nextDouble() * cell.nebula) * spreadFactor;
    for (SectorCell neighborCell in getAdjacentCells(cell)) {
      if (neighborCell.nebula == 0 && rnd.nextDouble() < nebulaSpreadProb) {
        double nextNeb = rnd.nextDouble() * cell.nebula;
        growNebula(neighborCell,nextNeb,rnd);
        //print("Growing neb: $cell (${cell.nebula}) -> $neighborCell ($nextNeb)");
      }
    }
  }

  void growIon(SectorCell cell, double strength, Random rnd, {spreadFactor = .25}) {
    cell.ionStorm = strength;
    double ionSpreadProb = (rnd.nextDouble() * cell.ionStorm) * spreadFactor;
    for (SectorCell neighborCell in getAdjacentCells(cell)) {
      if (neighborCell.ionStorm == 0 && rnd.nextDouble() < ionSpreadProb) {
        double nextIon = rnd.nextDouble() * cell.ionStorm;
        growIon(neighborCell,nextIon,rnd);
      }
    }
  }
}

class SectorCell extends GridCell {
  Planet? planet;
  StellarClass? starClass;
  bool starOne,blackHole;
  double nebula,ionStorm;
  int impulseSeed;

  SectorCell(super.coord, this.impulseSeed, {
    this.planet,this.starClass, this.starOne = false, this.blackHole = false,
    this.nebula = 0, this.ionStorm = 0
  });

  @override
  bool empty(Grid grid, {countPlayer = true}) { //print("Chceking enpty");
    if (!super.empty(grid)) return false;
    if (planet != null) return false;
    if (starClass != null) return false;
    if (starOne || blackHole) return false;
    if (nebula > 0 || ionStorm > 0) return false;
    return true;
  }

  @override
  String toString() {
    return "${super.toString()}, nebula: $nebula, ion: $ionStorm, planet: $planet, star: $starClass, blackhole: $blackHole";
  }
}

class System extends Level {
  String name;
  Set<System> links = HashSet();
  List<Planet> planets;
  int fedLvl, techLvl;
  bool starOne, blackHole;
  TrafficLvl traffic;
  bool scouted = false;
  bool visited = false;
  bool connected;
  StellarClass starClass;
  Map<SectorCell,ImpulseLevel> impMapCache = {};

  System(this.name,this.starClass,this.fedLvl,this.techLvl,this.planets,Random rnd,
      {this.blackHole = false,this.starOne = false, this.traffic = TrafficLvl.normal, this.connected = false,
      nebFact = .02, ionFact = .01, bhFact = .1, mapSize = 8}) {
    map = createSystemMap(mapSize,nebFact,ionFact,bhFact,rnd);
  }

  bool addLink(System sys, {linkback = false, required bool update}) { //modify tech/fed levels?
    if (this != sys && links.add(sys)) { //use trafficLvl?
      if (sys.connected) setConnection(true, update: update); //print("$name <-> ${sys.name}, links: ${links.length}");
      return (linkback || sys.addLink(this,linkback: true, update: update));
    }
    return false;
  }

  setConnection(bool c, {update = true}) {
    if (connected != c) {
      connected = c;
      if (connected && update) {
        for (System link in links) {
          link.setConnection(true);
        }
      }
    }
  }

  void scout() {
    scouted = true;
    for (Planet planet in planets) {
      planet.known = true;
    }
  }

  void updateLevels(Random rnd) {
    int techSum = techLvl, fedSum = fedLvl; //print("Updating Fed: $fedLvl");
    for (System system in links) {
      techSum += system.techLvl;
      fedSum += system.fedLvl;
    }
    int tl = (techSum / (links.length)).round();
    int fl =  (fedSum / (links.length)).round();
    techLvl = min(Rng.biasedRndInt(rnd,mean: tl,min: 0, max: max(tl * 1,100)),100);
    fedLvl = min(Rng.biasedRndInt(rnd,mean: fl ,min: 0, max: max(fl * 1,100)),100);
    //print("$name -> $fedLvl -> $fl -> ${links.length}");
    for (Planet planet in planets) {
      planet.techLvl = Rng.biasedRndInt(rnd,mean: techLvl,min: 0, max: 100);
      planet.fedLvl = Rng.biasedRndInt(rnd,mean: fedLvl,min: 0, max: 100);
      planet.export = planet.getRndExport();
      planet.updateDescription();
    }
  }

  SystemMap createSystemMap(int size, double nebulaFactor, double ionFactor, double blackFactor, Random rnd) {
    Map<Coord3D,SectorCell> cells = {};
    for (int x=0;x<size;x++) {
      for (int y=0;y<size;y++) {
        for (int z=0;z<size;z++) {
          double neb = (nebulaFactor > rnd.nextDouble() ? 1 : 0);
          double ion = (ionFactor > rnd.nextDouble() ? 1 : 0);
          final c = Coord3D(x, y, z);
          if (neb == 1) print("System: $name, neb: $neb -> $c");
          cells.putIfAbsent(c, () => SectorCell(c,rnd.nextInt(999999),nebula: neb, ionStorm: ion));
        }
      }
    }

    final map = SystemMap(size, cells);
    for (int x=0;x<size;x++) {
      for (int y=0;y<size;y++) {
        for (int z=0;z<size;z++) {
          final c = map.cells[Coord3D(x, y, z)]; //use copy
          if (c != null) {
            if (c.nebula == 1) { //print("System: $name, Adding nebula -> ${c.coord}");
              map.growNebula(c,rnd.nextDouble(),rnd);
            }
            if (c.ionStorm == 1) {
              map.growIon(c,rnd.nextDouble(),rnd);
            }
          }
        }
      }
    }

    if (blackFactor > rnd.nextDouble()) {
      map.rndCell(rnd).blackHole = true;
    }

    final List<SectorCell> npCells = map.cells.values.where((c) => c.planet == null && c.blackHole == false).toList();
    if (npCells.length > planets.length) {
      npCells.shuffle(rnd);
      for (int i = 0; i < planets.length; i++) {
        npCells[i].planet = planets[i];
      }
      npCells[planets.length].starClass = starClass;
    }

    return map;
  }

  String shortString({bool showVisit = false}) {
    return "$name (🛡$fedLvl,⚙$techLvl)${(showVisit && visited) ? '*' : ''}";
  }

  @override String toString() {
    StringBuffer linksStr = StringBuffer();
    for (int i=0;i<links.length;i++) {
      linksStr.write(" ${links.elementAt(i).name} ");
    }
    StringBuffer planetsStr = StringBuffer();
    for (int i=0;i<planets.length;i++) {
      planetsStr.write(" ${planets.elementAt(i).name} ");
    }
    return "$name fed: $fedLvl tech: $techLvl (${links.length} links,${traffic.name}): $linksStr planets: $planetsStr \n";
  }

  @override
  bool operator ==(Object other) => other is System && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

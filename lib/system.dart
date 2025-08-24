import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:space_fugue/descriptors.dart';
import 'package:space_fugue/planet.dart';

import 'galaxy.dart';

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

class System {
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

  System(this.name,this.starClass,this.fedLvl,this.techLvl,this.planets,
      {this.blackHole = false,this.starOne = false, this.traffic = TrafficLvl.normal, this.connected = false});


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

  void updateLevels(Galaxy galaxy) {
    int techSum = techLvl, fedSum = fedLvl; //print("Updating Fed: $fedLvl");
    for (System system in links) {
      techSum += system.techLvl;
      fedSum += system.fedLvl;
    }
    int tl = (techSum / (links.length)).round();
    int fl =  (fedSum / (links.length)).round();
    techLvl = min(galaxy.biasedRndInt(mean: tl,min: 0, max: max(tl * 1,100)),100);
    fedLvl = min(galaxy.biasedRndInt(mean: fl ,min: 0, max: max(fl * 1,100)),100);
    //print("$name -> $fedLvl -> $fl -> ${links.length}");
    for (Planet planet in planets) {
      planet.techLvl = galaxy.biasedRndInt(mean: techLvl,min: 0, max: 100);
      planet.fedLvl = galaxy.biasedRndInt(mean: fedLvl,min: 0, max: 100);
      planet.export = planet.getRndExport();
      planet.updateDescription();
    }
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

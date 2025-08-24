import 'package:flutter/material.dart';
import 'package:space_fugue/fugue_model.dart';
import 'package:space_fugue/galaxy.dart';
import 'package:space_fugue/planet.dart';
import 'package:space_fugue/player.dart';
import 'package:space_fugue/ship.dart';
import 'package:space_fugue/system.dart';
import 'message_log.dart';

class GameView extends StatefulWidget {
  final FugueModel fugueModel;
  final bool bigLog;
  final txtStyle = const TextStyle(color: Colors.white);

  const GameView(this.fugueModel, {required this.bigLog, super.key});

  @override
  State<StatefulWidget> createState() => GameViewState();
}

enum MainMenu {main,ship}
enum PlanetMenu {main,mod,repair,shipyard}

class GameViewState extends State<GameView> {

  MainMenu currMainMenu = MainMenu.main;
  PlanetMenu currPlanMenu = PlanetMenu.main;
  MessageLog? log;

  @override
  void initState() {
    super.initState();
    log = MessageLog(messageNotifier: widget.fugueModel.msgWorker.messageNotifier);
  }

  void setPlanetMenu(PlanetMenu menu) {
    setState(() { currPlanMenu = menu; });
  }

  void setMainMenu(MainMenu menu) {
    setState(() { currMainMenu = menu; });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: Colors.black,
        child: Center(child: Column(children: [
          switch(currMainMenu) {
            MainMenu.main => mainMenu(),
            MainMenu.ship => shipScreen(widget.fugueModel.player.ship),
          },
          spaceBlock(),
          widget.bigLog ? Expanded(child: log!) : SizedBox(height: 128, child: log!),
        ])));
  }

  void launch() {
    widget.fugueModel.launch();
    setPlanetMenu(PlanetMenu.main);
  }

  Color heatCol() {
    double hi = widget.fugueModel.currentHeat() /100;
    int v = (hi * 255).ceil();
    return Color.fromRGBO(v, 128, 255 - v, 1);
  }

  Color shipCol(Ship ship) {
    double hi = ship.energy / ship.battery.value;
    int v = (hi * 255).ceil();
    return Color.fromRGBO(255-v, v, 92, 1);
  }

  Widget mainMenu() {
    final fm = widget.fugueModel;
    final p = fm.player;
    return Column(children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Credits: ${p.credits}, Heat: ${fm.currentHeat()}",style: TextStyle(color: heatCol())),
        spaceBlock(vertical: false, w: 12),
        Text("Current System: ${p.system.shortString(showVisit: false)}",style: TextStyle(color: p.system.starClass.color)),
        if (p.planet != null) spaceBlock(vertical: false, w: 12),
        if (p.planet != null) Text("Current Planet: ${p.planet?.shortString() ?? '-'} ", style: TextStyle(color: p.planet?.color(fedTech: true))),
        menuAction(() => setMainMenu(MainMenu.ship), "🚀 ${p.ship.name}, ⚡ ${p.ship.energy}, damage: ${p.ship.damage}/${p.ship.hull.value}",col: shipCol(p.ship)),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [ //if (p.orbiting == null) const SizedBox(width: 8),
          menuAction(widget.fugueModel.energyScoop, p.orbiting == null ? "Scoop" : "System",bigButt: true), //if (p.orbiting == null)
          spaceBlock(vertical: false, w: 8 ),
          menuAction(widget.fugueModel.piracy, "Piracy", bigButt: true),
          spaceBlock(vertical: false, w: 8 ),
          menuAction(widget.fugueModel.warp, "Warp", bigButt: true),
        ])
      ])),
      spaceBlock(),
      p.planet != null
          ? planetMenu(p)
          : orbitMenu(p),
      p.planet != null ? const Divider() : spaceBlock(),
      p.planet != null
          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (currPlanMenu != PlanetMenu.main) menuAction(() => setPlanetMenu(PlanetMenu.main), "Return", bigButt: true),
            if (currPlanMenu != PlanetMenu.main) spaceBlock(vertical: false),
            menuAction(launch,"Launch",bigButt: true)])
          : SingleChildScrollView(scrollDirection: Axis.horizontal,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Links: ",style: widget.txtStyle),
              spaceBlock(vertical: false),
              sectorMenu(p)
            ])),
    ]);
  }

  Widget sectorMenu(Player p) {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(p.system.links.length, (i) {
          System link = p.system.links.elementAt(i);
          Text linkTxt = Text(link.shortString(), style: TextStyle(color: link.starClass.color));
          return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                border: link.visited ? Border.all(color: link.starClass.color, width: 1) : null
              ),
              child: TextButton(
                  onPressed: () => widget.fugueModel.goLink(link),
                  child: linkTxt));
        }));
  }

  Widget orbitMenu(Player p) {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(p.system.planets.length, (i) {
          Planet planet = p.system.planets.elementAt(i);
          double lum = planet.color(fedTech: false).computeLuminance() + planet.color(fedTech: true).computeLuminance()/2;
          Color c = lum > .5 ? Colors.black : Colors.white;
          return Row(children: [DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    planet.color(fedTech: false),
                    planet.color(fedTech: true),
                  ],
                ),
                //color: bkgCol,
                borderRadius: BorderRadiusDirectional.circular(16),
                border: Border.all(color: Colors.white,width: 1),
              ),
              child: TextButton(
                  onPressed: () => widget.fugueModel.goPlan(planet),
                  child: Text("${p.tradeTarget?.planet == planet ? '💲' : '🪐'}"
                      " ${planet.shortString()}", //,${p.ship.subTurnsToPlanet(planet).floor()}",
                      style:  TextStyle(color: c)), //planet.color(fedTech: true)))
              )
          ),
          const SizedBox(width: 8)]);
        })));
  }

  Widget planetMenu(Player player) {
    Planet? planet = player.planet;
    if (planet != null) {
      return switch(currPlanMenu) {
        PlanetMenu.main => mainPlanetMenu(planet),
        PlanetMenu.mod => shipModMenu(player.ship),
        PlanetMenu.repair => repairMenu(),
        PlanetMenu.shipyard => throw UnimplementedError(),
      };
    } else { throw Exception("WTF"); }
  }

  Widget menuAction(void Function() fun, String txt, {bool plan=false, bool bigButt=false, Color col = Colors.white, Color bkgCol = Colors.black}) {
    return bigButt
        ? ElevatedButton(onPressed: () { fun(); }, child: Text(txt,style: TextStyle(color: bkgCol)))
        : TextButton(onPressed: () {
          if (plan) widget.fugueModel.landCheck();
          fun();
          }, child: Text(txt,style: TextStyle(backgroundColor: bkgCol, color: col)));
  }

  Widget shipScreen(Ship ship) {
    List<ShipSystem> shipSystems = ship.systems();
    return Column(children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(shipSystems.length, (i) {
          ShipSystem system = shipSystems.elementAt(i);
          return Container(
              decoration: BoxDecoration(
                color: system.type.color,
                border: Border.all(color: Colors.black, width: 1)
              ),
              child: Column(
            children: [
              Text(" ${system.type.name} ", style: const TextStyle(color: Colors.black)),
              Text(" ${system.value} ", style: const TextStyle(color: Colors.black))
            ],
          ));
        })
      )),
      spaceBlock(),
      menuAction(() => setMainMenu(MainMenu.main), "Return",bigButt: true),
    ]);
  }

  Widget shipModMenu(Ship ship) {
    List<ShipSystem> shipSystems = ship.systems();
    return Column(children: [ SingleChildScrollView(scrollDirection: Axis.horizontal,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:
      List.generate(shipSystems.length, (i) {
        ShipSystem system = shipSystems.elementAt(i);
        return Container(
            decoration: BoxDecoration(
                color: system.type.color,
                border: Border.all(color: Colors.black, width: 1)
            ),
            child: Column(
          children: [
            menuAction(() => widget.fugueModel.modShip(system),"${system.type.name}: ${system.value} / ${system.max()}"),
            Text("(${system.type.cost} credits)",style: const TextStyle(color: Colors.black))
          ],
        ));
      })
      )),
    ]);
  }

  Widget repairMenu() {
    final fm = widget.fugueModel;
    return Column(
      children: [
        Row(children: [
          menuAction(fm.repair, "Repair (${fm.costRepair} credit per hull damage)"),
          menuAction(fm.recharge, "Recharge (${fm.costRecharge} credit per energy unit)"),
          menuAction(() => fm.repair(all: true), "Repair all"),
          menuAction(() => fm.recharge(all: true), "Recharge all")
        ]),
      ]
    );
  }

  Widget mainPlanetMenu(Planet planet) {
    final fm = widget.fugueModel;
    return SingleChildScrollView(scrollDirection: Axis.horizontal,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (planet.resLvl == DistrictLvl.heavy) menuAction(fm.spy, "Spy",plan:true),
      if (planet.resLvl.index >=  DistrictLvl.medium.index) menuAction(fm.hack,"Hack",plan:true),
      if (planet.resLvl.index >= DistrictLvl.light.index) menuAction(fm.scout,"Scout",plan:true),
      if (planet.commLvl == DistrictLvl.heavy) menuAction(fm.broadcast,"Broadcast (${fm.costBroadcast} credits)",plan:true),
      if (planet.commLvl.index >=  DistrictLvl.medium.index)
        menuAction(fm.tradeMission,"Trade Mission",plan:true),
      if (planet.commLvl.index >= DistrictLvl.light.index) menuAction(fm.shoplift,"Shoplift",plan:true),
      if (planet.dustLvl == DistrictLvl.heavy) menuAction(fm.bioHack, "Bio-Hacking (${fm.costBioHack} credits)",plan:true),
      if (planet.dustLvl.index >=  DistrictLvl.medium.index)
        menuAction(() => setPlanetMenu(PlanetMenu.mod),"Ship Modification",plan:true),
      if (planet.dustLvl.index >= DistrictLvl.light.index)
        menuAction(() => setPlanetMenu(PlanetMenu.repair),"Repair/Recharge",plan:true),
    ]));
  }

  Widget spaceBlock({bool vertical = true, double w = 4, double h = 8}) {
    return SizedBox(width: vertical ? null : w, height: vertical ? h : null);
  }

}
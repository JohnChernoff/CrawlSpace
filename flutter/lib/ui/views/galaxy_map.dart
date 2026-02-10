import 'dart:math';
import 'package:crawlspace_engine/agent.dart';
import 'package:crawlspace_engine/fugue_engine.dart';
import 'package:crawlspace_engine/galaxy.dart';
import 'package:crawlspace_engine/system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/widget/force_directed_graph_controller.dart';
import 'package:flutter_force_directed_graph/widget/force_directed_graph_widget.dart';
import '../graphs/graph.dart';
import '../../main.dart';
import '../../options.dart';
import 'galaxy_view.dart';

class GalaxyMap extends StatefulWidget {
  final FugueEngine fugueModel;
  final GalaxyMapLegend legend;
  const GalaxyMap(this.fugueModel,this.legend,{super.key});

  @override
  State<StatefulWidget> createState() => GalaxyMapState();

}

class GalaxyMapState extends State<GalaxyMap> {
  late final FugueGraph fugueGraph;
  late final ForceDirectedGraphController<System> _controller =
  ForceDirectedGraphController(graph: fugueGraph.graph, minScale: .001, maxScale: 5);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {//print("InitState for Galaxy View");
    super.initState();
    fugueGraph = FugueGraph(widget.fugueModel.galaxy);
    _controller.scale = .1;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.needUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    FugueEngine fm = widget.fugueModel;
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          final deltaY = event.scrollDelta.dy;
          setState(() {
            _controller.scale *= deltaY > 0 ? 0.9 : 1.1;
            _controller.scale = _controller.scale.clamp(_controller.minScale, _controller.maxScale);
            _controller.needUpdate();
          });
        }
      },
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _controller.scale *= details.scale;
            _controller.scale = _controller.scale.clamp(_controller.minScale, _controller.maxScale);
            _controller.needUpdate();
          });
        },
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("img/galaxy.jpg"),fit: BoxFit.fill)
          ),
          //color: Colors.black,
          child: ForceDirectedGraphWidget(
            controller: _controller,
            nodesBuilder: (context, data) { //print("Building: ${data.name}");
              return  InkWell(onTap: (fm.gameOver) ? null : () => fm.layerTransitController.newSystem(fm.player,data),
                  child: fugueOptions.getBool(FugueOption.fancyGraph) ? fancyNode(data) : boxSystem(data)
              ); //check if currently on a planet;
            },
            edgesBuilder: (context, a, b, distance) {
              return Container(
                width: distance,
                height: 8,
                color: a == fm.player.system || b == fm.player.system
                    ? Colors.white
                    : Colors.brown,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget fancyNode(System system) {
    return switch (widget.fugueModel.agentAt(system)) {
      AgentSystemReport.none => boxSystem(system),
      AgentSystemReport.lastKnown => starSystem(system),
      AgentSystemReport.current => starSystem(system, hex: true),
    };
  }

  Widget boxSystem(System system) {
    return Container(
        decoration: BoxDecoration(
          color: systemColor(system),
          borderRadius: widget.fugueModel.player.system != system ? const BorderRadius.all(Radius.elliptical(72,24)) : null,
        ),
        width: 128,
        height: 36,
        alignment: Alignment.center,
        child: Text(system.name));
  }

  Widget starSystem(System system, {bool hex = false}) {
    return CustomPaint(
        painter: hex ? HexagramPainter(systemColor(system)) : PentagramPainter(systemColor(system)),
        child: SizedBox(
          width: 255,
          height: 128,
          child: Center(
            child: Text(system.name, style: const TextStyle(color: Colors.white)),
          ),
        ));
  }

  Color systemColor(System system) {
    FugueEngine fm = widget.fugueModel;
    int planV = 0;
    if (widget.legend == GalaxyMapLegend.planets || widget.legend == GalaxyMapLegend.all) {
      planV = ((system.planets.length / Galaxy.maxPlanets) * 222).floor() + 32;
    }
    return fm.player.system == system ? Colors.yellow :
    fm.galaxy.homeSystem == system ? Colors.white : switch(widget.legend) {
      GalaxyMapLegend.star => Color(system.starClass.color.argb),
      GalaxyMapLegend.planets => Color.fromRGBO(planV, planV, planV, 1),
      GalaxyMapLegend.fed => Color.fromRGBO(0,0,((system.fedLvl / 100) * 222).floor() + 32, 1), //blue
      GalaxyMapLegend.tech => Color.fromRGBO(0,((system.techLvl / 100) * 222).floor() + 32, 0,1), //green
      GalaxyMapLegend.all => Color.fromRGBO(planV,((system.techLvl / 100) * 222).floor() + 32, ((system.fedLvl / 100) * 222).floor() + 32, 1),
      GalaxyMapLegend.history => switch(fm.agentAt(system)) {
        AgentSystemReport.none => fm.player.tradeTarget != null && system.planets.contains(fm.player.tradeTarget?.planet)
            ? Colors.green : system.visited ? Colors.blue : Colors.purple,
        AgentSystemReport.lastKnown => Colors.grey,
        AgentSystemReport.current => Colors.red,
      }
    };
  }

}

class PentagramPainter extends CustomPainter {
  final Color color;

  PentagramPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double radius = min(size.width, size.height) / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final Path path = Path();

    for (int i = 0; i < 5; i++) {
      final double angle = (pi / 2) + (2 * pi * i * 2 / 5);
      final double x = centerX + radius * cos(angle);
      final double y = centerY - radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HexagramPainter extends CustomPainter {
  final Color color;

  HexagramPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double radius = min(size.width, size.height) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    Path triangle(double rotation) {
      final Path path = Path();
      for (int i = 0; i < 3; i++) {
        final angle = (2 * pi * i / 3) + rotation;
        final x = center.dx + radius * cos(angle);
        final y = center.dy + radius * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    canvas.drawPath(triangle(0), paint);
    canvas.drawPath(triangle(pi), paint); // flipped triangle
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

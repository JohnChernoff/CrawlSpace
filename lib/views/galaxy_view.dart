import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:space_fugue/fugue_model.dart';
import 'package:space_fugue/message_log.dart';
import '../galaxy_map.dart';
import 'ascii_view.dart';

class GalaxyView extends StatefulWidget {
  final FugueModel fugueModel;
  const GalaxyView(this.fugueModel, {super.key});

  @override
  State<StatefulWidget> createState() => GalaxyViewState();
}

enum MapMode {full,half,hidden}
enum GalaxyMapLegend {star,planets,fed,tech,all,history}

class GalaxyViewState extends State<GalaxyView> {
  bool hideMap = false;
  GalaxyMapLegend legend = GalaxyMapLegend.history;

  @override
  Widget build(BuildContext context) { //print("Building Galaxy View: Player -> ${widget.fugueModel.player.system.name}");
    MapMode mapMode;
    if (kIsWeb) {
      mapMode = hideMap ? MapMode.hidden : MapMode.half;
    } else {
      mapMode = hideMap || MediaQuery.of(context).orientation == Orientation.portrait ? MapMode.hidden : MapMode.full;
    }
    FugueModel fm = widget.fugueModel;
    return Container(color: Colors.black,
        child: Column(children: [
          if (mapMode != MapMode.full) Expanded(
              flex: 1,
              child: fm.gameOver //TODO: autoscroll
                  ? MessageLog(messageNotifier: fm.msgWorker.messageNotifier,postGame: true) : hideMap
                    ? GestureDetector(onDoubleTap: () {setState(() { hideMap = false; }); }, child: AsciiView(fm))
                    : AsciiView(fm)
          ),
          Container(color: Colors.black, height: 12),
          if (mapMode != MapMode.hidden) Expanded(
            flex: 4,
            child: GalaxyMap(fm,legend),
          ),
          if (mapMode != MapMode.hidden) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              legendRow(),
              ElevatedButton(onPressed: () { setState(() { hideMap = true; });}, child: const Text("Hide Map (Double-Click to Revert)")),
          ]),
        ],
        ));
  }

  Widget legendRow() {
    return Row(children: [
      const Text("Galaxy Map Legend: ",style: TextStyle(color: Colors.white)),
      Row(children: List.generate(GalaxyMapLegend.values.length, (i) {
        GalaxyMapLegend leg = GalaxyMapLegend.values.elementAt(i);
        return Row(children: [
          Radio<GalaxyMapLegend>(
              value: leg,
              groupValue: legend,
              onChanged: (GalaxyMapLegend? leg) {
                setState(() { if (leg != null) legend = leg; });
              }),
          Text(leg.name,style: const TextStyle(color: Colors.white),)
        ]);
      })),
    ]);
  }
}

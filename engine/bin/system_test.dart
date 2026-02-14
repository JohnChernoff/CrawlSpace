import 'dart:math';
import 'package:crawlspace_engine/fugue_engine.dart';
import 'package:crawlspace_engine/galaxy.dart';

void main() {
  final engine = FugueEngine(Galaxy("Testlandia"), "Zug", seed: Random().nextInt(999));
  engine.populateSystem(engine.playerShip!.pilot.system);
}
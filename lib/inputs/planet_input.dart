import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../fugue_model.dart';

enum PlanetAction {
  spy,hack,scout,tavern,trade,broadcast,dna,repair,upgrade,shop
}

class LaunchIntent extends Intent {
  const LaunchIntent();
}

class PlanetActionIntent extends Intent {
  final PlanetAction action;
  const PlanetActionIntent(this.action);
}

class PlanetInput extends StatelessWidget {
  final Widget child;
  final FugueModel fm;

  const PlanetInput(this.child, this.fm, {super.key});

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyS):
        const PlanetActionIntent(PlanetAction.scout),
        LogicalKeySet(LogicalKeyboardKey.keyH):
        const PlanetActionIntent(PlanetAction.hack),
        LogicalKeySet(LogicalKeyboardKey.keyA):
        const PlanetActionIntent(PlanetAction.spy),
        LogicalKeySet(LogicalKeyboardKey.keyV):
        const PlanetActionIntent(PlanetAction.tavern),
        LogicalKeySet(LogicalKeyboardKey.keyT):
        const PlanetActionIntent(PlanetAction.trade),
        LogicalKeySet(LogicalKeyboardKey.keyB):
        const PlanetActionIntent(PlanetAction.broadcast),
        LogicalKeySet(LogicalKeyboardKey.keyR):
        const PlanetActionIntent(PlanetAction.repair),
        LogicalKeySet(LogicalKeyboardKey.keyU):
        const PlanetActionIntent(PlanetAction.upgrade),
        LogicalKeySet(LogicalKeyboardKey.keyB):
        const PlanetActionIntent(PlanetAction.shop),
        LogicalKeySet(LogicalKeyboardKey.keyG):
        const PlanetActionIntent(PlanetAction.dna),
        LogicalKeySet(LogicalKeyboardKey.keyL):
        const LaunchIntent(),
      },
      actions: {
        PlanetActionIntent: CallbackAction<PlanetActionIntent>(
            onInvoke: (intent) {
              switch(intent.action) {
                case PlanetAction.spy:
                  fm.planetsideController.spy();
                case PlanetAction.hack:
                  fm.planetsideController.hack();
                case PlanetAction.scout:
                  fm.planetsideController.scout();
                case PlanetAction.tavern:
                  fm.planetsideController.spy();
                case PlanetAction.trade:
                  fm.planetsideController.getTradeMission();
                case PlanetAction.broadcast:
                  fm.planetsideController.broadcast();
                case PlanetAction.dna:
                  fm.planetsideController.bioHack();
                case PlanetAction.repair:
                  //fm.planetsideController.re();
                case PlanetAction.upgrade:
                  //fm.planetsideController.up();
                case PlanetAction.shop:
                  fm.planetsideController.shop();
              }
              return null;
            }),
        LaunchIntent: CallbackAction<LaunchIntent>(
            onInvoke: (_) {
              fm.planetsideController.launch();
              return null;
            }),
      },
      child: child,
    );
  }
}

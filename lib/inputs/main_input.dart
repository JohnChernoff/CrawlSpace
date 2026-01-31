import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../coord_3d.dart';
import '../fugue_model.dart';

class CancelToMainIntent extends Intent {
  const CancelToMainIntent();
}

class DirectionIntent extends Intent {
  final int dx,dy,dz;
  const DirectionIntent(this.dx,this.dy,this.dz);
}

class OpenInventoryIntent extends Intent {
  const OpenInventoryIntent();
}

class OpenPlanetMenuIntent extends Intent {
  const OpenPlanetMenuIntent();
}

class HyperSpaceIntent extends Intent {
  const HyperSpaceIntent();
}

class ScannerModeIntent extends Intent {
  final bool forwards;
  final ScannerMode? mode;
  const ScannerModeIntent({this.mode,this.forwards = true});
}

class LoiterIntent extends Intent {
    const LoiterIntent();
}

const downComboKey = LogicalKeyboardKey.shift;
const upComboKey = LogicalKeyboardKey.keyZ;

class MainInput extends StatelessWidget {
  final Widget child;
  final FugueModel fm;
  const MainInput(this.child, this.fm, {super.key});

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowUp):
        const DirectionIntent(0, -1, 0),
        LogicalKeySet(LogicalKeyboardKey.arrowDown):
        const DirectionIntent(0, 1, 0),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft):
        const DirectionIntent(-1, 0, 0),
        LogicalKeySet(LogicalKeyboardKey.arrowRight):
        const DirectionIntent(1, 0, 0),
        LogicalKeySet(LogicalKeyboardKey.end):
        const DirectionIntent(-1, 1, 0),
        LogicalKeySet(LogicalKeyboardKey.home):
        const DirectionIntent(-1, -1, 0),
        LogicalKeySet(LogicalKeyboardKey.pageUp):
        const DirectionIntent(1, -1, 0),
        LogicalKeySet(LogicalKeyboardKey.pageDown):
        const DirectionIntent(1, 1, 0),

        LogicalKeySet(LogicalKeyboardKey.arrowUp,downComboKey):
        const DirectionIntent(0, -1, -1),
        LogicalKeySet(LogicalKeyboardKey.arrowDown,downComboKey):
        const DirectionIntent(0, 1, -1),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft,downComboKey):
        const DirectionIntent(-1, 0, -1),
        LogicalKeySet(LogicalKeyboardKey.arrowRight,downComboKey):
        const DirectionIntent(1, 0, -1),
        LogicalKeySet(LogicalKeyboardKey.end,downComboKey):
        const DirectionIntent(-1, 1, -1),
        LogicalKeySet(LogicalKeyboardKey.home,downComboKey):
        const DirectionIntent(-1, -1, -1),
        LogicalKeySet(LogicalKeyboardKey.pageUp,downComboKey):
        const DirectionIntent(1, -1, -1),
        LogicalKeySet(LogicalKeyboardKey.pageDown,downComboKey):
        const DirectionIntent(1, 1, -1),
        LogicalKeySet(LogicalKeyboardKey.clear,downComboKey):
        const DirectionIntent(0, 0, -1),

        LogicalKeySet(LogicalKeyboardKey.arrowUp,upComboKey):
        const DirectionIntent(0, -1, 1),
        LogicalKeySet(LogicalKeyboardKey.arrowDown,upComboKey):
        const DirectionIntent(0, 1, 1),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft,upComboKey):
        const DirectionIntent(-1, 0, 1),
        LogicalKeySet(LogicalKeyboardKey.arrowRight,upComboKey):
        const DirectionIntent(1, 0, 1),
        LogicalKeySet(LogicalKeyboardKey.end,upComboKey):
        const DirectionIntent(-1, 1, 1),
        LogicalKeySet(LogicalKeyboardKey.home,upComboKey):
        const DirectionIntent(-1, -1, 1),
        LogicalKeySet(LogicalKeyboardKey.pageUp,upComboKey):
        const DirectionIntent(1, -1, 1),
        LogicalKeySet(LogicalKeyboardKey.pageDown,upComboKey):
        const DirectionIntent(1, 1, 1),
        LogicalKeySet(LogicalKeyboardKey.clear,upComboKey):
        const DirectionIntent(0, 0, 1),

        LogicalKeySet(LogicalKeyboardKey.clear):
        const LoiterIntent(),

        LogicalKeySet(LogicalKeyboardKey.keyP):
        const OpenPlanetMenuIntent(),

        LogicalKeySet(LogicalKeyboardKey.keyH):
        const HyperSpaceIntent(),

        LogicalKeySet(LogicalKeyboardKey.keyI):
        const OpenInventoryIntent(),

        LogicalKeySet(LogicalKeyboardKey.keyS):
        const ScannerModeIntent(mode: null),

        LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.shift):
        const ScannerModeIntent(mode: null, forwards: false),
      },
      actions: {
        DirectionIntent: CallbackAction<DirectionIntent>(
          onInvoke: (intent) { //print("Moving ship");
            fm.vectorShip(
              fm.playerShip,
              Coord3D(intent.dx, intent.dy, intent.dz),
            );
            return null;
          },
        ),
        OpenInventoryIntent: CallbackAction(
          onInvoke: (_) {
            fm.inputMode = InputMode.inventory;
            return null;
          },
        ),
        OpenPlanetMenuIntent: CallbackAction(
          onInvoke: (_) {
            fm.visitPlanet();
            return null;
          },
        ),
        HyperSpaceIntent: CallbackAction(
          onInvoke: (_) {
            fm.hyperSpaceMenu();
            return null;
          },
        ),
        ScannerModeIntent: CallbackAction<ScannerModeIntent>(
          onInvoke: (intent) {
            if (intent.mode == null) {
              fm.toggleScannerMode(forwards: intent.forwards);
            }
            return null;
          }
        ),
        LoiterIntent: CallbackAction<LoiterIntent>(
            onInvoke: (_) {
              fm.loiter();
              return null;
            }
        ),
      },
      child: child,
    );
  }
}

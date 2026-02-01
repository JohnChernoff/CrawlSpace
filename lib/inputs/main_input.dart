import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/menu_controller.dart';
import '../controllers/scanner_controller.dart';
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

class ImpulseIntent extends Intent {
  final bool enter;
  const ImpulseIntent(this.enter);
}

class HyperSpaceIntent extends Intent {
  const HyperSpaceIntent();
}

class ScannerModeIntent extends Intent {
  final bool forwards;
  final ScannerMode? mode;
  const ScannerModeIntent({this.mode,this.forwards = true});
}

class ScannerSelectionIntent extends Intent {
  final bool up;
  const ScannerSelectionIntent(this.up);
}

class ScannerTargetIntent extends Intent {
  final bool ship;
  const ScannerTargetIntent(this.ship);
}

class FireIntent extends Intent {
  const FireIntent();
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

        LogicalKeySet(LogicalKeyboardKey.keyX, LogicalKeyboardKey.shift):
        const ImpulseIntent(true),

        LogicalKeySet(LogicalKeyboardKey.keyX):
        const ImpulseIntent(false),

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

        LogicalKeySet(LogicalKeyboardKey.keyQ):
        const ScannerSelectionIntent(true),

        LogicalKeySet(LogicalKeyboardKey.keyA):
        const ScannerSelectionIntent(false),

        LogicalKeySet(LogicalKeyboardKey.keyT):
        const ScannerTargetIntent(false),

        LogicalKeySet(LogicalKeyboardKey.keyT, LogicalKeyboardKey.shift):
        const ScannerTargetIntent(true),

        LogicalKeySet(LogicalKeyboardKey.keyF):
        const FireIntent(),

      },
      actions: {
        DirectionIntent: CallbackAction<DirectionIntent>(
          onInvoke: (intent) { //print("Moving ship");
            fm.movementController.vectorShip(
              fm.playerShip,
              Coord3D(intent.dx, intent.dy, intent.dz),
            );
            return null;
          },
        ),
        OpenInventoryIntent: CallbackAction(
          onInvoke: (_) {
            fm.menuController.inputMode = InputMode.inventory;
            return null;
          },
        ),
        OpenPlanetMenuIntent: CallbackAction(
          onInvoke: (_) {
            fm.menuController.visitPlanet();
            return null;
          },
        ),
        HyperSpaceIntent: CallbackAction(
          onInvoke: (_) {
            fm.menuController.hyperSpaceMenu();
            return null;
          },
        ),
        ScannerModeIntent: CallbackAction<ScannerModeIntent>(
          onInvoke: (intent) {
            if (intent.mode == null) {
              fm.scannerController.toggleScannerMode(forwards: intent.forwards);
            }
            return null;
          }
        ),
        LoiterIntent: CallbackAction<LoiterIntent>(
            onInvoke: (_) {
              fm.movementController.loiter();
              return null;
            }
        ),
        ImpulseIntent: CallbackAction<ImpulseIntent>(
            onInvoke: (intent) {
              if (intent.enter) {
                fm.layerTransitController.createAndEnterImpulse();
              } else {
                fm.layerTransitController.exitImpulse(fm.playerShip);
              }
              return null;
            }
        ),
        ScannerSelectionIntent: CallbackAction<ScannerSelectionIntent>(
            onInvoke: (intent) {
              fm.scannerController.selectScannedObject(intent.up);
              return null;
            }
        ),
        ScannerTargetIntent: CallbackAction<ScannerTargetIntent>(
            onInvoke: (intent) {
              if (intent.ship) {
                fm.scannerController.targetShipFromScannedCell();
              } else {
                fm.scannerController.targetScannedObject(fm.playerShip,fm.scannerController.currentScanSelection);
              }
              return null;
            }
        ),
        FireIntent: CallbackAction<FireIntent>(
            onInvoke: (_) {
              fm.combatController.fire(fm.playerShip);
              return null;
            }
        ),
      },
      child: child,
    );
  }
}

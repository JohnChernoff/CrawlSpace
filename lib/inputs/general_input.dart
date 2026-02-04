import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../fugue_model.dart';
import '../main.dart';

class HelpIntent extends Intent {
  const HelpIntent();
}

class FullScreenMenu extends Intent {
  const FullScreenMenu();
}

class CancelToMainIntent extends Intent {
  const CancelToMainIntent();
}

enum AudioChoice {nextTrack,togglePause}
class AudioIntent extends Intent {
  final AudioChoice choice;
  const AudioIntent(this.choice);
}

mixin GeneralInputMixin {
  FugueModel get fm;

  Map<LogicalKeySet, Intent> get generalShortcuts => {
    LogicalKeySet(LogicalKeyboardKey.keyM):
    const AudioIntent(AudioChoice.togglePause),

    LogicalKeySet(LogicalKeyboardKey.keyN):
    const AudioIntent(AudioChoice.nextTrack),

    LogicalKeySet(LogicalKeyboardKey.keyH, LogicalKeyboardKey.shift):
    const HelpIntent(),

    LogicalKeySet(LogicalKeyboardKey.space):
    const FullScreenMenu(),
  };

  Map<Type, Action<Intent>> get generalActions => {
    HelpIntent: CallbackAction<HelpIntent>(
        onInvoke: (_) {
          rootBundle.loadString('assets/help/help.txt').then((file) => fm.msgController.addMsg(file));
          return null;
        }
    ),
    FullScreenMenu: CallbackAction<FullScreenMenu>(
        onInvoke: (_) { //print("Full Screen Toggle");
          fm.menuController.fullscreen = !fm.menuController.fullscreen;
          fm.update();
          return null;
        }
    ),
    AudioIntent: CallbackAction<AudioIntent>(
        onInvoke: (intent) {
          switch(intent.choice) {
            case AudioChoice.nextTrack: fm.audioController.newTrack(); break;
            case AudioChoice.togglePause: {
              if (fuguePlayer.state == PlayerState.paused) {
                fuguePlayer.resume();
              } else {
                fuguePlayer.pause();
              }
            }
          }
          return null;
        }
    ),
  };
}
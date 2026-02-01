import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../fugue_model.dart';
import '../main.dart';

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
  };

  Map<Type, Action<Intent>> get generalActions => {
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
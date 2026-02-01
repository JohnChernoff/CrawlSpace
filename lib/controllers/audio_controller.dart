import 'package:audioplayers/audioplayers.dart';
import 'package:space_fugue/controllers/fugue_controller.dart';
import '../main.dart';

enum MusicalMood {intro,danger,planet,space}

class AudioController extends FugueController {
  MusicalMood mood = MusicalMood.intro;

  AudioController(super.fm);

  bool isPlayingMusic() => fuguePlayer.state == PlayerState.playing || fuguePlayer.state == PlayerState.completed;
  void newTrack({MusicalMood? newMood}) {
    if (isPlayingMusic()) {
      if (newMood != null) mood = newMood;
      if (fuguePlayer.state == PlayerState.playing) {
        fm.glog("Searching for new track...");
        AssetSource track; do {
          track = AssetSource(getTrack());
        } while (fuguePlayer.source.toString() == track.toString());
        fm.glog("New Mood Track: ${track.toString()}");
        fuguePlayer.stop().then((v) => fuguePlayer.play(track));
      } else {
        fuguePlayer.play(AssetSource(getTrack()));
      }
    }
  }
  String getTrack() => switch(mood) {
    MusicalMood.danger => "audio/tracks/danger${fm.rnd.nextInt(4)+1}.mp3",
    MusicalMood.planet => "audio/tracks/planet${fm.rnd.nextInt(4)+1}.mp3",
    MusicalMood.space => "audio/tracks/wandering${fm.rnd.nextInt(4)+1}.mp3",
    MusicalMood.intro => "audio/tracks/intro${fm.rnd.nextInt(2)+1}.mp3", //"audio/tracks/intro1.mp3",
  };
}
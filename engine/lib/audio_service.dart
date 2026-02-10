enum MusicalMood { intro, danger, planet, space }

abstract class AudioService {
  void setMood(MusicalMood mood);
  void playNewTrack();
}

class NullAudioService implements AudioService {
  @override void setMood(MusicalMood mood) {}
  @override void playNewTrack() {}
}

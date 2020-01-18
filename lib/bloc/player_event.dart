import 'package:flute_music_player/flute_music_player.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PlayerEvent {}

class Play extends PlayerEvent {
  final Song song;
  Play({this.song});
}

class Pause extends PlayerEvent {}

class Next extends PlayerEvent {}

class Previous extends PlayerEvent {}

class StopSong extends PlayerEvent {}

class ResumeSong extends PlayerEvent {}

class SeekTo extends PlayerEvent {
  final double value;
  SeekTo(this.value);
}

class ToggleReplay extends PlayerEvent {}

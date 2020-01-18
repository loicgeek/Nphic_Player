import 'package:flute_music_player/flute_music_player.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PlayerState {}

class InitialPlayerState extends PlayerState {}

class PlayerPlaying extends PlayerState {
  final Song song;
  PlayerPlaying({this.song});
}

class PlayerPaused extends PlayerState {
  final Song song;
  PlayerPaused({this.song});
}

class PlayerStopped extends PlayerState {}

class PlayerMuted extends PlayerState {}

class PlayerLoadingSong extends PlayerState {}

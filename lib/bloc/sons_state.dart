import 'package:flute_music_player/flute_music_player.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SongsState {}

class InitialSongsState extends SongsState {}

class AllSongsLoaded extends SongsState {
  List<Song> songs;
  AllSongsLoaded({this.songs});
}

class AllSongsLoading extends SongsState {}

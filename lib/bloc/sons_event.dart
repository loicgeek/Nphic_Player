import 'package:meta/meta.dart';
import 'package:neumorphism_player/bloc/bloc.dart';

@immutable
abstract class SongsEvent {}

class LoadAllSongs extends SongsEvent {}

class YieldStateEvent extends SongsEvent {
  final SongsState songsState;
  YieldStateEvent({this.songsState});
}

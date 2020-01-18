import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flute_music_player/flute_music_player.dart';
import './bloc.dart';
import 'package:rxdart/rxdart.dart';

class SongsBloc extends Bloc<SongsEvent, SongsState> {
  @override
  SongsState get initialState => InitialSongsState();

  BehaviorSubject<List<Song>> allSongsStream =
      new BehaviorSubject<List<Song>>.seeded([]);

  @override
  Stream<SongsState> mapEventToState(
    SongsEvent event,
  ) async* {
    if (event is LoadAllSongs) {
      yield AllSongsLoading();
      MusicFinder m = new MusicFinder();
      m.setHandlePermissions(true);
      m.setExecuteAfterPermissionGranted(true);
      loadSongsF();
    }
    if (event is YieldStateEvent) {
      yield event.songsState;
    }
  }

  dynamic loadSongsF() async {
    List<Song> songs = await MusicFinder.allSongs();
    allSongsStream.add(songs);
    this.add(YieldStateEvent(songsState: AllSongsLoaded(songs: songs)));
  }
}

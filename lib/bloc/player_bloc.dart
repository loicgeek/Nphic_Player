import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:neumorphism_player/bloc/bloc.dart';
import 'package:neumorphism_player/bloc/sons_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  var musicFinder = new MusicFinder();
  List<Song> songs;
  final SongsBloc songsBloc;
  BehaviorSubject<double> position = new BehaviorSubject<double>.seeded(0.0);
  BehaviorSubject<double> duration = new BehaviorSubject<double>.seeded(100.0);
  BehaviorSubject<Song> currentStream = new BehaviorSubject<Song>();
  BehaviorSubject<bool> replay = new BehaviorSubject<bool>.seeded(false);

  PlayerBloc({this.songsBloc}) {
    musicFinder.setDurationHandler((Duration d) {
      duration.add(d.inSeconds.toDouble());
    });
    musicFinder.setPositionHandler((Duration d) {
      position.add(d.inSeconds.toDouble());
    });
    musicFinder.setCompletionHandler(() {
      if (this.replay.value == true) {
        this.add(Play(song: this.currentStream.value));
      } else {
        this.add(Next());
      }
    });

    this.songsBloc.listen((state) {
      if (state is AllSongsLoaded) {
        this.songs = state.songs;
        this.currentStream.add(this.songs[0]);
      }
    });

    this.initMediaNotifications();
  }

  void initMediaNotifications() {
    MediaNotification.setListener('play', (f) {
      print('playing');
      print(f);
    });
    MediaNotification.setListener('pause', (f) {
      this.add(Pause());
      print(f);
    });

    MediaNotification.setListener('select', (f) {
      print('select');
      print(f);
    });

    MediaNotification.setListener('prev', (f) {
      this.add(Previous());
      print(f);
    });

    MediaNotification.setListener('next', (f) {
      if (this.replay.value == true) {
        this.add(Play(song: this.currentStream.value));
      } else {
        this.add(Next());
      }
    });
  }

  @override
  PlayerState get initialState => PlayerStopped();

  @override
  Stream<PlayerState> mapEventToState(
    PlayerEvent event,
  ) async* {
    if (event is ResumeSong) {
      if (!(this.state is PlayerPaused)) {
        return;
      }
      this.add(Play(song: this.currentStream.value));
      this.currentStream.add(this.currentStream.value);
    }
    if (event is Play) {
      print(this.state);
      if (this.state is PlayerPlaying ||
          this.state is PlayerPaused ||
          this.state is PlayerStopped) {
        try {
          await musicFinder.stop();
        } catch (_) {}
      }
      var isOkay = await musicFinder.play(event.song.uri, isLocal: true);
      this.currentStream.add(event.song);
      MediaNotification.showNotification(
          title: this.currentStream.value.title,
          author: this.currentStream.value.artist);
      yield PlayerPlaying(song: event.song);
    }
    if (event is Pause) {
      if (!(this.state is PlayerPlaying)) {
        return;
      }
      await musicFinder.pause();
      yield PlayerPaused();
      MediaNotification.showNotification(
          title: this.currentStream.value.title,
          author: this.currentStream.value.artist,
          isPlaying: false);
    }
    if (event is Next) {
      await musicFinder.stop();
      Song toPlay = this.songs[
          (this.songs.indexOf(this.currentStream.value) + 1) %
              this.songs.length];
      this.add(Play(song: toPlay));
    }

    if (event is Previous) {
      await musicFinder.stop();
      Song toPlay = this.songs[
          (this.songs.indexOf(this.currentStream.value) - 1) %
              this.songs.length];
      this.add(Play(song: toPlay));
    }

    if (event is SeekTo) {
      await musicFinder.seek(event.value);
    }
    if (event is StopSong) {
      await musicFinder.stop();
      yield PlayerStopped();
    }

    if (event is ToggleReplay) {
      this.replay.add(!this.replay.value);
    }
  }
}

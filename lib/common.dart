import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:neumorphism_player/bloc/bloc.dart';
import 'package:neumorphism_player/nm_box.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';

class NMButton extends StatelessWidget {
  final bool down;
  final IconData icon;
  final VoidCallback onPressed;
  const NMButton({this.down, this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: down ? nMboxInvert : nMbox,
      child: IconButton(
        icon: Icon(
          icon,
          color: down ? fCD : fCL,
        ),
        onPressed: () {
          this.onPressed();
        },
      ),
    );
  }
}

class NMCard extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  const NMCard({this.active, this.icon, this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      decoration: nMbox,
      child: Row(
        children: <Widget>[
          Icon(icon, color: fCL),
          SizedBox(width: 15),
          Text(
            label,
            style: TextStyle(
                color: fCD, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Spacer(),
          Container(
            decoration: active ? nMboxInvertActive : nMboxInvert,
            width: 70,
            height: 40,
            child: Container(
              margin: active
                  ? EdgeInsets.fromLTRB(35, 5, 5, 5)
                  : EdgeInsets.fromLTRB(5, 5, 35, 5),
              decoration: nMbtn,
            ),
          ),
        ],
      ),
    );
  }
}

class PlayButton extends StatefulWidget {
  Song song;
  PlayerBloc playerBloc;

  PlayButton({Key key, this.song, this.playerBloc}) : super(key: key);

  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: this.widget.playerBloc.asBroadcastStream(),
      builder: (context, snapshot) {
        return NMButton(
          down: snapshot.data is PlayerPlaying,
          icon: Icons.play_arrow,
          onPressed: () {
            if (snapshot.data is PlayerPlaying) {
              return;
            }
            if (snapshot.data is PlayerPaused) {
              this.widget.playerBloc.add(ResumeSong());
              return;
            }
            this
                .widget
                .playerBloc
                .add(Play(song: this.widget.playerBloc.currentStream.value));
          },
        );
      },
    );
  }
}

class ReplayButton extends StatefulWidget {
  Song song;
  PlayerBloc playerBloc;

  ReplayButton({Key key, this.song, this.playerBloc}) : super(key: key);

  @override
  _ReplayButtonState createState() => _ReplayButtonState();
}

class _ReplayButtonState extends State<ReplayButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: this.widget.playerBloc.replay,
      builder: (context, snapshot) {
        return NMButton(
          down: snapshot.data ?? false,
          icon: Icons.replay,
          onPressed: () {
            this.widget.playerBloc.add(ToggleReplay());
          },
        );
      },
    );
  }
}

class StopButton extends StatefulWidget {
  Song song;
  PlayerBloc playerBloc;

  StopButton({Key key, this.song, this.playerBloc}) : super(key: key);

  @override
  _StopButtonState createState() => _StopButtonState();
}

class _StopButtonState extends State<StopButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: this.widget.playerBloc.asBroadcastStream(),
      builder: (context, snapshot) {
        return NMButton(
          down: snapshot.data is PlayerStopped,
          icon: Icons.stop,
          onPressed: () {
            this.widget.playerBloc.add(StopSong());
          },
        );
      },
    );
  }
}

class PauseButton extends StatefulWidget {
  PlayerBloc playerBloc;

  PauseButton({this.playerBloc});
  @override
  _PauseButtonState createState() => _PauseButtonState();
}

class _PauseButtonState extends State<PauseButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
        stream: this.widget.playerBloc.asBroadcastStream(),
        builder: (context, snapshot) {
          return NMButton(
            down: snapshot.data is PlayerPaused,
            icon: Icons.pause,
            onPressed: () {
              this.widget.playerBloc.add(
                    Pause(),
                  );
            },
          );
        });
  }
}

class NextButton extends StatelessWidget {
  PlayerBloc playerBloc;

  NextButton({this.playerBloc});
  @override
  Widget build(BuildContext context) {
    return NMButton(
      down: false,
      icon: Icons.skip_next,
      onPressed: () {
        this.playerBloc.add(Next());
      },
    );
  }
}

class PreviousButton extends StatelessWidget {
  PlayerBloc playerBloc;
  PreviousButton({Key key, this.playerBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NMButton(
      down: false,
      icon: Icons.skip_previous,
      onPressed: () {
        this.playerBloc.add(Previous());
      },
    );
  }
}


  void initMediaNotifications() {
    MediaNotification.setListener('play', (f) {
      print('playing');
      print(f);
    });
    MediaNotification.setListener('pause', (f) {
      print(f);
    });

    MediaNotification.setListener('select', (f) {
      print('select');
      print(f);
    });

    MediaNotification.setListener('prev', (f) {
       print(f);
    });

    MediaNotification.setListener('next', (f) {
      
    });
  }

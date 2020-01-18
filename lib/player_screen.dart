import 'dart:io';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neumorphism_player/bloc/bloc.dart';
import 'package:neumorphism_player/common.dart';
import 'package:neumorphism_player/nm_box.dart';

double transLimit = 1250;

class PlayerScreen extends StatefulWidget {
  final Song song;

  const PlayerScreen({Key key, this.song}) : super(key: key);
  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: mC,
      body: Container(
        height: screenHeight,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: nMboxInvert,
                  height: screenHeight * .08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      NMButton(
                        down: false,
                        icon: Icons.arrow_back_ios,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      NMButton(
                        down: false,
                        icon: Icons.more_vert,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder<Song>(
                stream: playerBloc.currentStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Hero(
                        tag: snapshot.data.id,
                        child: Container(
                          decoration: nMbox.copyWith(
                              image: DecorationImage(
                            image: snapshot.data.albumArt != null
                                ? FileImage(File('${snapshot.data.albumArt}'))
                                : AssetImage("assets/images/transparentv2.png"),
                            fit: BoxFit.cover,
                          )),
                          height: screenHeight * .35,
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
              StreamBuilder<Song>(
                stream: playerBloc.currentStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: nMbox,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${snapshot.data.title}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '${snapshot.data?.artist}',
                                    style: TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8, top: 2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Album / ',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${snapshot.data?.album}',
                                    style: TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 0,
                ),
                child: PlayerSlider(
                  playerBloc: playerBloc,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ReplayButton(playerBloc: playerBloc),
                    StopButton(playerBloc: playerBloc),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    PreviousButton(playerBloc: playerBloc),
                    PauseButton(playerBloc: playerBloc),
                    PlayButton(
                      playerBloc: playerBloc,
                      song: widget.song,
                    ),
                    NextButton(playerBloc: playerBloc),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerSlider extends StatefulWidget {
  PlayerBloc playerBloc;

  PlayerSlider({this.playerBloc});
  @override
  _PlayerSliderState createState() => _PlayerSliderState();
}

class _PlayerSliderState extends State<PlayerSlider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.green.shade300,
            inactiveTrackColor: fCL.withOpacity(0.25),
            trackHeight: 5,
            thumbColor: mCL,
            trackShape: RectangularSliderTrackShape(
              disabledThumbGapWidth: 2,
            ),
            overlayColor: mCL.withOpacity(0.75),
          ),
          child: StreamBuilder<double>(
              stream: widget.playerBloc.position,
              builder: (context, snapshot) {
                return Slider(
                  value: snapshot.data ?? 1,
                  min: 0,
                  max: widget.playerBloc.duration.value ?? 12,
                  onChanged: (val) {},
                  onChangeEnd: (value) {
                    widget.playerBloc.add(SeekTo(value));
                  },
                );
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            StreamBuilder<double>(
                stream: widget.playerBloc.position ?? 1,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      formatDuration(snapshot.data),
                      style: TextStyle(
                          color: fCD,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    );
                  }
                  return Container();
                }),
            StreamBuilder<Object>(
                stream: widget.playerBloc.duration ?? 1,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      formatDuration(snapshot.data),
                      style: TextStyle(
                          color: fCD,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    );
                  }
                  return Container();
                }),
          ],
        ),
      ],
    );
  }

  String formatDuration(double seconds) {
    int min = seconds ~/ 60;
    int sec = (seconds % 60).toInt();
    String finalValue;
    if (min <= 9) {
      if (sec <= 9) {
        finalValue = "0$min:0$sec";
      } else {
        finalValue = "0$min:$sec";
      }
    } else {
      if (sec <= 9) {
        finalValue = "$min:0$sec";
      } else {
        finalValue = "$min:$sec";
      }
    }
    return finalValue;
  }
}

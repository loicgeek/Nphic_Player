import 'dart:io';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neumorphism_player/bloc/bloc.dart';
import 'package:neumorphism_player/common.dart';
import 'package:neumorphism_player/nm_box.dart';
import 'package:neumorphism_player/player_screen.dart';
import 'package:neumorphism_player/widgets/home_music_item.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MediaNotification.setListener('pause', () {
      print('pause clicked');
    });

    MediaNotification.setListener('play', () {
      print('play clicked');
    });

    MediaNotification.setListener('next', () {
      print('next clicked');
    });

    MediaNotification.setListener('prev', () {
      print('prev clicked');
    });

    MediaNotification.setListener('select', () {
      print('selec clicked');
    });

    MediaNotification.showNotification(title: 'Title', author: 'Song author');
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('resumed');
    }
    if (state == AppLifecycleState.inactive) {
      print('inactive');
    }
    if (state == AppLifecycleState.detached) {
      print('detached');
    }
    if (state == AppLifecycleState.paused) {
      print('paused');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: nMboxInvert,
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: 1,
                        child: Container(
                          decoration: nMbox,
                          child: Center(
                            child: Text(
                              'NPhic Player',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    NMButton(
                      down: false,
                      icon: Icons.search,
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: CustomSearchHintDelegate(
                            hintText: 'Search ',
                            songsBloc: BlocProvider.of<SongsBloc>(context),
                            playerBloc: BlocProvider.of<PlayerBloc>(context),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<SongsBloc, SongsState>(
              builder: (context, state) {
                if (state is AllSongsLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is AllSongsLoaded) {
                  return Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height - 72,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                        )),
                        child: ListView.builder(
                          itemCount: state.songs.length + 1,
                          itemBuilder: (context, idx) {
                            if (idx == state.songs.length) {
                              return Container(
                                height: 110,
                              );
                            }
                            return HomeMusicItem(
                              song: state.songs[idx],
                              playerBloc: BlocProvider.of<PlayerBloc>(context),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 25,
                        left: 0,
                        right: 0,
                        child: _buildMp3Controller(),
                      )
                    ],
                  );
                }
                return Container();
              },
            ),
          ],
        ),
        onWillPop: () {
          return showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    size: 40,
                    color: Colors.yellow,
                  ),
                  Expanded(child: Text('Alert !!')),
                ],
              ),
              contentTextStyle: TextStyle(
                color: Colors.green,
                fontSize: 16,
              ),
              content: Container(
                decoration: nMboxInvert,
                child: Row(children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'If you want Continue then use the ** HOME ** Button, Would You really exit ? '),
                    ),
                  ),
                ]),
              ),
              actions: <Widget>[
                InkWell(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: nMbox,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.green,
                    ),
                  ),
                  onTap: () {
                    return Navigator.pop(context, false);
                  },
                ),
                InkWell(
                  onTap: () {
                    BlocProvider.of<PlayerBloc>(context).add(StopSong());
                    return Navigator.pop(context, true);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: nMbox,
                    child: Icon(
                      Icons.exit_to_app,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _buildMp3Controller() {
    return Container(
      height: 80,
      decoration: nMbox.copyWith(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        children: <Widget>[
          StreamBuilder<Song>(
            stream: BlocProvider.of<PlayerBloc>(context).currentStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 8.0),
                  child: Text(
                    '${snapshot.data.artist}- ${snapshot.data.title}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }
              return Container();
            },
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                StreamBuilder<Song>(
                  stream: BlocProvider.of<PlayerBloc>(context).currentStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return PlayerScreen();
                              },
                            ),
                          );
                        },
                        child: Hero(
                          tag: snapshot.data.id,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: snapshot.data?.albumArt == null
                                    ? AssetImage(
                                        "assets/images/transparentv2.png")
                                    : FileImage(
                                        File('${snapshot.data.albumArt}')),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
                PreviousButton(
                  playerBloc: BlocProvider.of<PlayerBloc>(context),
                ),
                PauseButton(
                  playerBloc: BlocProvider.of<PlayerBloc>(context),
                ),
                PlayButton(
                  song:
                      BlocProvider.of<PlayerBloc>(context).currentStream.value,
                  playerBloc: BlocProvider.of<PlayerBloc>(context),
                ),
                NextButton(
                  playerBloc: BlocProvider.of<PlayerBloc>(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSearchHintDelegate extends SearchDelegate {
  SongsBloc songsBloc;
  PlayerBloc playerBloc;
  CustomSearchHintDelegate({
    String hintText,
    this.songsBloc,
    this.playerBloc,
  }) : super(
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return <Widget>[
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {},
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    List<String> sug = ['La foine', 'Booba'];
    return StreamBuilder<List<Song>>(
        stream: this.songsBloc.allSongsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data.where((t) {
                return t.artist
                        .toLowerCase()
                        .contains(this.query.toLowerCase() ?? '') ||
                    t.title
                        .toLowerCase()
                        .contains(this.query.toLowerCase() ?? "") ||
                    t.album
                        .toLowerCase()
                        .contains(this.query.toLowerCase() ?? '');
              }).map((Song s) {
                return HomeMusicItem(
                    song: s, playerBloc: this.playerBloc, isSearch: true);
              }).toList(),
            );
          } else {
            return Container();
          }
        });
  }
}

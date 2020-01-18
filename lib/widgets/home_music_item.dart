import 'dart:io';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neumorphism_player/bloc/bloc.dart';
import 'package:neumorphism_player/nm_box.dart';
import 'package:neumorphism_player/player_screen.dart';

class HomeMusicItem extends StatefulWidget {
  Song song;
  PlayerBloc playerBloc;
  bool isSearch;
  HomeMusicItem({Key key, this.song, this.playerBloc, this.isSearch = false})
      : super(key: key);

  @override
  _HomeMusicItemState createState() => _HomeMusicItemState();
}

class _HomeMusicItemState extends State<HomeMusicItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.playerBloc.add(Play(song: widget.song));
        if (widget.isSearch) {
          print('is searc');
          Navigator.of(context).pop();
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return PlayerScreen(song: widget.song);
            },
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        height: 100,
        decoration: nMbox,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        child: Row(
          children: <Widget>[
            Container(
              height: 100,
              width: 100,
              decoration: nMbox.copyWith(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: FadeInImage(
                  placeholder: AssetImage("assets/images/transparentv2.png"),
                  image: FileImage(File('${widget.song.albumArt}')),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<Song>(
                  stream: widget.playerBloc.currentStream,
                  builder: (context, snapshot) {
                    return Container(
                      decoration: (snapshot.hasData &&
                              snapshot.data.id == widget.song.id)
                          ? nMboxInvert.copyWith(
                              border: Border.all(
                              color: Colors.green,
                            ))
                          : nMbox,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${widget.song.title}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${widget.song.artist}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}

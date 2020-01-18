import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neumorphism_player/bloc/bloc.dart';
import 'package:neumorphism_player/home.dart';

double transLimit = 1250;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  SongsBloc songsBloc = SongsBloc();
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayerBloc>(
          create: (context) => PlayerBloc(songsBloc: songsBloc),
        ),
        BlocProvider<SongsBloc>(
          create: (context) => songsBloc..add(LoadAllSongs()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}

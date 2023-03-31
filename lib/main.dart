import 'package:flutter/material.dart';
import 'package:flutter_game_with_flutter_flame/view/game_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Realtime UFO Shooting Game',
      debugShowCheckedModeBanner: false,
      home: GameView(),
    );
  }
}

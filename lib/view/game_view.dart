import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_game_with_flutter_flame/view/lobby_view.dart';

import '../logic/game_logic.dart';

class GameView extends StatefulWidget {
  const GameView({Key? key}) : super(key: key);

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late final MyGame _game;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _game = MyGame(
      onGameStateUpdate: (position, health) async {
        // TODO: handle gmae state update here
      },
      onGameOver: (playerWon) async {
        // TODO: handle when the game is over here
      },
    );

    // await for a frame so that the widget mounts
    await Future.delayed(Duration.zero);

    if (mounted) {
      _openLobbyDialog();
    }
  }

  void _openLobbyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LobbyView(
          onGameStarted: (gameId) async {
            // handle game start here
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
          GameWidget(game: _game)
        ],
      ),
    );
  }
}

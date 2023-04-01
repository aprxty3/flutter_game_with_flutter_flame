import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_game_with_flutter_flame/view/lobby_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../logic/game_logic.dart';
import '../main.dart';

class GameView extends StatefulWidget {
  const GameView({Key? key}) : super(key: key);

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late final MyGame _game;

  RealtimeChannel? _gameChannel;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _game = MyGame(
      onGameStateUpdate: (position, health) async {
        ChannelResponse response;
        do {
          response = await _gameChannel!.send(
            type: RealtimeListenTypes.broadcast,
            event: 'game_state',
            payload: {'x': position.x, 'y': position.y, 'health': health},
          );
          await Future.delayed(Duration.zero);
          setState(() {});
        } while (response == ChannelResponse.rateLimited && health <= 0);
      },
      onGameOver: (playerWon) async {
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: ((context) {
            return AlertDialog(
              title: Text(playerWon ? 'You Won!' : 'You lost...'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await supabase.removeChannel(_gameChannel!);
                    _openLobbyDialog();
                  },
                  child: const Text('Back to Lobby'),
                ),
              ],
            );
          }),
        );
      },
    );

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
            await Future.delayed(Duration.zero);

            setState(() {});

            _game.startNewGame();

            _gameChannel = supabase.channel(gameId,
                opts: const RealtimeChannelConfig(ack: true));

            _gameChannel!.on(RealtimeListenTypes.broadcast,
                ChannelFilter(event: 'game_state'), (payload, [_]) {
              final position =
                  Vector2(payload['x'] as double, payload['y'] as double);
              final opponentHealth = payload['health'] as int;
              _game.updateOpponent(
                position: position,
                health: opponentHealth,
              );

              if (opponentHealth <= 0) {
                if (!_game.isGameOver) {
                  _game.isGameOver = true;
                  _game.onGameOver(true);
                }
              }
            }).subscribe();
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

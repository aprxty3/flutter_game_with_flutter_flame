import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';

class LobbyView extends StatefulWidget {
  const LobbyView({
    required this.onGameStarted,
  });

  final void Function(String gameId) onGameStarted;

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  List<String> _userids = [];
  bool _loading = false;

  final myUserId = const Uuid().v4();

  late final RealtimeChannel _lobbyChannel;

  @override
  void initState() {
    super.initState();

    _lobbyChannel = supabase.channel(
      'lobby',
      opts: const RealtimeChannelConfig(self: true),
    );
    _lobbyChannel.on(RealtimeListenTypes.presence, ChannelFilter(event: 'sync'),
        (payload, [ref]) {
      // Update the lobby count
      final presenceState = _lobbyChannel.presenceState();

      setState(() {
        _userids = presenceState.values
            .map((presences) =>
                (presences.first as Presence).payload['user_id'] as String)
            .toList();
      });
    }).on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'game_start'),
        (payload, [_]) {
      // Start the game if someone has started a game with you
      final participantIds = List<String>.from(payload['participants']);
      if (participantIds.contains(myUserId)) {
        final gameId = payload['game_id'] as String;
        widget.onGameStarted(gameId);
        Navigator.of(context).pop();
      }
    }).subscribe(
      (status, [ref]) async {
        if (status == 'SUBSCRIBED') {
          await _lobbyChannel.track({'user_id': myUserId});
        }
      },
    );
  }

  @override
  void dispose() {
    supabase.removeChannel(_lobbyChannel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lobby'),
      content: _loading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Text('${_userids.length} users waiting'),
      actions: [
        TextButton(
          onPressed: _userids.length < 2
              ? null
              : () async {
                  setState(
                    () {
                      _loading = true;
                    },
                  );

                  final opponentId =
                      _userids.firstWhere((userId) => userId != myUserId);
                  final gameId = const Uuid().v4();

                  await _lobbyChannel.send(
                    type: RealtimeListenTypes.broadcast,
                    event: 'game_start',
                    payload: {
                      'participants': [
                        opponentId,
                        myUserId,
                      ],
                      'game_id': gameId,
                    },
                  );
                },
          child: const Text('start'),
        ),
      ],
    );
  }
}

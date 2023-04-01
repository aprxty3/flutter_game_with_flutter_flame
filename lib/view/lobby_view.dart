import 'package:flutter/material.dart';

class LobbyView extends StatefulWidget {
  const LobbyView({
    required this.onGameStarted,
  });

  final void Function(String gameId) onGameStarted;

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  final List<String> _userids = [];
  bool _loading = false;

  final myUserId = '';

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
                  setState(() {
                    _loading = true;
                  });
                },
          child: const Text('start'),
        ),
      ],
    );
  }
}

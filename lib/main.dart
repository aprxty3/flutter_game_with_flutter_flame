import 'package:flutter/material.dart';
import 'package:flutter_game_with_flutter_flame/view/game_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://bwbdrvvkkugnitjejevx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3YmRydnZra3Vnbml0amVqZXZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODAzNjQxNzMsImV4cCI6MTk5NTk0MDE3M30.jxaJ94PCt0QnaGZ4f9E1iJcyhb9U1oG_-XM7zsH1XhI',
    realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 40),
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

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
